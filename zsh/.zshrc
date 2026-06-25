# Aliases
source ~/dotfiles/zsh/aliases.zsh

# AI helpers (gcai, ask, greview, explain)
source ~/dotfiles/zsh/ai.zsh

# Prompt
source ~/dotfiles/zsh/prompt.zsh

# Dotfiles bin
export PATH="$PATH:$HOME/dotfiles/bin"

# Android
export PATH="$PATH:$HOME/Library/Android/sdk/emulator"

# Node
export NODE_OPTIONS="--max-old-space-size=8192"

# rbenv
eval "$(rbenv init - zsh)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

# Local zsh files (gitignored, never committed)
for f in ~/dotfiles/zsh/*.local.zsh; do [ -f "$f" ] && source "$f"; done

# Machine-specific config (gitignored, never committed)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Chalkboard CLI
alias cbc="$HOME/cb-cli/cb"

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

# >>>> BEGIN MANAGED DEVIN BLOCK >>>>
# Add ~/.local/bin to PATH for devin
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
# <<<< END MANAGED DEVIN BLOCK <<<<
