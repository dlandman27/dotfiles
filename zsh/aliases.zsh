# Git
alias gaa='git add .'
alias gb='git branch'
alias gcl='git clone'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gdiff='git diff'
alias gbd='git branch -D'
alias gf='git fetch'
alias gfo='git fetch origin'
alias gfap='git fetch && git pull'
alias gl='git log --oneline --graph --decorate -20'
alias gpull='git pull'
alias gpush='git push'
alias gr='git rebase'
alias grh='git reset --hard'
alias grb='git rebranch'
alias gsp='git stash pop'
alias gss='git stash'
alias gst='git status'

# List unique branches in order of most-recent checkout. Usage: gblog [count]
function gblog() {
  local count="${1:-20}"
  git reflog | awk '/checkout:/ {print $NF}' | awk '!seen[$0]++' | head -n "$count"
}

# Shell
alias code='cursor'
alias cls='clear'
alias zedit='nano ~/dotfiles/zsh/aliases.zsh'
alias zrestart='source ~/.zshrc'

function zhelp() {
  echo ""
  echo "=== Custom Shell Commands ==="
  echo ""
  echo "-- Git --"
  echo "  gdiff        git diff"
  echo "  gf           git fetch"
  echo "  gfo          git fetch origin"
  echo "  gfap         git fetch && git pull"
  echo "  gpull        git pull"
  echo "  gpush        git push"
  echo "  gr           git rebase"
  echo "  gl           git log (graph, last 20)"
  echo "  gcl          git clone"
  echo "  gcm          git commit -m"
  echo "  gaa          git add ."
  echo "  gst          git status"
  echo "  gco          git checkout"
  echo "  gcob         git checkout -b"
  echo "  gb           git branch"
  echo "  gbd          git branch -D"
  echo "  gss          git stash"
  echo "  gsp          git stash pop"
  echo "  grh          git reset --hard"
  echo "  grb          git rebranch <branch> <base>: recreate <branch> off an updated <base>"
  echo "  gblog        List recently checked-out branches (default 20)"
  echo ""
  echo "-- Shell --"
  echo "  cls          Clear terminal"
  echo "  zedit        Edit aliases in nano"
  echo "  zrestart     Reload ~/.zshrc"
  echo "  zhelp        Show this help menu"
  echo ""
}
