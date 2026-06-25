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
