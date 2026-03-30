# Git
alias gaa='git add .'
alias gcl='git clone'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gdiff='git diff'
alias grh='git reset --hard'
alias gst='git status'

# Shell
alias cls='clear'
alias zedit='nano ~/dotfiles/zsh/aliases.zsh'
alias zrestart='source ~/.zshrc'

function zhelp() {
  echo ""
  echo "=== Custom Shell Commands ==="
  echo ""
  echo "-- Git --"
  echo "  gdiff        git diff"
  echo "  gcl          git clone"
  echo "  gcm          git commit -m"
  echo "  gaa          git add ."
  echo "  gst          git status"
  echo "  gco          git checkout"
  echo "  gcob         git checkout -b"
  echo "  grh          git reset --hard"
  echo ""
  echo "-- Shell --"
  echo "  cls          Clear terminal"
  echo "  zedit        Edit aliases in nano"
  echo "  zrestart     Reload ~/.zshrc"
  echo "  zhelp        Show this help menu"
  echo ""
}
