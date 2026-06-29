#!/bin/zsh
# AI helpers that hit Claude headlessly (claude -p) so you don't have to open
# the REPL and run a slash command. Same pattern as gprc: gather context in the
# shell, pipe it into `claude -p "<instruction>"`, use stdout.

# Generate a commit message from the staged diff and confirm before committing.
# Infers the ticket scope from the branch name (e.g. rb-358-foo -> rb-358).
# Usage: gcai   (then [y] commit as-is, [e] edit in $EDITOR, [N] abort)
gcai() {
  local diff
  diff=$(git diff --cached) || return 1
  if [[ -z "$diff" ]]; then
    echo "Nothing staged. Stage changes first (e.g. gaa)." >&2
    return 1
  fi

  local branch ticket_line
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ "$branch" =~ '^([a-zA-Z]+)-([0-9]+)' ]]; then
    local ticket="${(L)match[1]}-${match[2]}"
    ticket_line="The branch maps to ticket $ticket — use it as the scope, e.g. 'fix($ticket): ...'."
  fi

  echo "Writing commit message with Claude..." >&2
  local msg
  msg=$(printf '%s' "$diff" | claude -p "Write a git commit message in Conventional Commits format (type(scope): summary) for this staged diff. The type MUST be one of: feat, fix, chore, refactor, docs, test, perf, build, ci, style, revert. Summary line under 72 chars, then a blank line and a short body explaining the why only if it's non-trivial. ${ticket_line} Output only the commit message — no code fences, no preamble.") || {
    echo "Claude failed." >&2
    return 1
  }

  if [[ -z "$msg" ]]; then
    echo "Got an empty message from Claude." >&2
    return 1
  fi

  echo
  echo "$msg"
  echo

  local reply
  read -k 1 "reply?Commit this? [y/e/N] "
  echo
  case "$reply" in
    y|Y)
      git commit -m "$msg"
      ;;
    e|E)
      local tmp
      tmp=$(mktemp) || return 1
      printf '%s\n' "$msg" > "$tmp"
      "${EDITOR:-nano}" "$tmp"
      git commit -F "$tmp"
      rm -f "$tmp"
      ;;
    *)
      echo "Aborted."
      ;;
  esac
}

# Ask Claude a one-off question without entering the REPL. Reads piped stdin as
# extra context if present, so it also works as a pipe target.
# Usage: ask "how do I squash the last 3 commits"
#        some-cmd 2>&1 | ask "what does this mean"
ask() {
  if [[ ! -t 0 ]]; then
    local input
    input=$(cat)
    if [[ $# -eq 0 ]]; then
      printf '%s' "$input" | claude -p "Explain this concisely."
    else
      claude -p "$*

CONTEXT:
$input"
    fi
    return
  fi

  if [[ $# -eq 0 ]]; then
    echo "usage: ask \"your question\"" >&2
    return 1
  fi
  claude -p "$*"
}

# Review the current branch's diff against a base branch for likely bugs.
# Read-only — never modifies anything. Defaults to beta, like gprc.
# Usage: greview            -> review vs beta
#        greview master     -> review vs master
greview() {
  local base="${1:-beta}"
  git fetch origin "$base" >/dev/null 2>&1
  local diff
  diff=$(git diff "origin/$base"...HEAD)
  if [[ -z "$diff" ]]; then
    echo "No diff against origin/$base." >&2
    return 1
  fi
  echo "Reviewing diff against origin/$base with Claude..." >&2
  printf '%s' "$diff" | claude -p "Review this git diff as a senior engineer. Call out likely bugs, edge cases, and correctness issues as a concise bulleted list. Skip style nitpicks. If nothing looks serious, say so."
}

# Explain piped error output or command results in plain language.
# Usage: some-cmd 2>&1 | explain
explain() {
  if [[ -t 0 ]]; then
    echo "usage: <command> 2>&1 | explain" >&2
    return 1
  fi
  local input
  input=$(cat)
  printf '%s' "$input" | claude -p "Explain this command output or error in plain language: what it means and the most likely fix. Be concise."
}

# Draft a PR body with Claude from the diff + commits against a base branch.
# Usage: _gprc_ai_body <base>   (prints the markdown body to stdout)
_gprc_ai_body() {
  local base="$1" tmpl branch ticket_line
  tmpl="$(git rev-parse --show-toplevel)/.github/pull_request_template.md"
  branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$branch" =~ '^([a-zA-Z]+)-([0-9]+)' ]]; then
    local ticket="${(U)match[1]}-${match[2]}"
    ticket_line="The ticket is $ticket — put a markdown link to https://linear.app/chalkboard/issue/$ticket in the \"Issue ticket number and link\" section."
  fi
  echo "Drafting PR body with Claude..." >&2
  {
    echo "COMMITS:"; git log "origin/$base"..HEAD --format='%s%n%b'
    echo; echo "DIFF:"; git diff "origin/$base"...HEAD
  } | claude -p "Write a GitHub PR description in GitHub-flavored markdown describing these changes. Fill in the template below from the commits and diff. Keep the checklist as-is, leave the Screenshots/Videos section's placeholders empty, and omit sections that don't apply. ${ticket_line} Output only the markdown body — no code fences, no preamble.$( [ -f "$tmpl" ] && printf '\n\nTEMPLATE:\n%s' "$(cat "$tmpl")" )"
}

# Open or edit a PR from the current branch to a base branch (defaults to beta).
# If a PR already exists for the branch, offers to edit its description instead.
# Prompts whether to have Claude draft the body; pass -a/--ai to skip the prompt.
# Usage: gprc              -> PR into beta (create or edit), asks about AI body
#        gprc master       -> same, into master
#        gprc -a           -> skip the prompt, use a Claude-drafted body
#        gprc -a master    -> same, into master
gprc() {
  local ai=0 base=""
  for arg in "$@"; do
    case "$arg" in
      -a|--ai) ai=1 ;;
      *) base="$arg" ;;
    esac
  done
  base="${base:-beta}"

  git push -u origin HEAD || return 1

  local existing body
  existing=$(gh pr view --json number --jq .number 2>/dev/null)

  # Edit an existing PR's description.
  if [[ -n "$existing" ]]; then
    if ! read -q "?PR #$existing already exists. Edit its description? [y/N] "; then
      echo; return
    fi
    echo
    if (( ! ai )) && read -q "?Draft the new body with Claude? [y/N] "; then ai=1; fi
    echo
    if (( ! ai )); then
      gh pr edit
      return
    fi
    body=$(_gprc_ai_body "$base") || { echo "Claude failed; opening interactive edit." >&2; gh pr edit; return; }
    gh pr edit --body "$body"
    return
  fi

  # Create a new PR.
  if (( ! ai )); then
    if read -q "?Draft the PR body with Claude? [y/N] "; then ai=1; fi
    echo
  fi
  if (( ! ai )); then
    gh pr create --base "$base"
    return
  fi
  body=$(_gprc_ai_body "$base") || { echo "Claude failed; falling back to interactive create." >&2; gh pr create --base "$base"; return; }
  gh pr create --base "$base" --body "$body"
}
