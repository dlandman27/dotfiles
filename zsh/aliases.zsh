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
alias restart='exec zsh'

# Manage the dotfiles repo.
#   dotfiles          open the control-center TUI (same as `dot`)
#   dotfiles pull     pull latest and reload the shell
#   dotfiles help     show the command reference (zhelp)
function dotfiles() {
  case "$1" in
    ""|ui|tui)
      dot
      ;;
    pull)
      git -C ~/dotfiles pull && source ~/.zshrc && echo "dotfiles updated and reloaded"
      ;;
    help)
      zhelp
      ;;
    *)
      echo "usage: dotfiles [pull|help]  (no args opens the TUI)"
      return 1
      ;;
  esac
}

function zhelp() {
  local title=$'\033[1;36m' header=$'\033[1;33m' cmd=$'\033[0;32m' reset=$'\033[0m'
  echo ""
  echo "${title}=== Custom Shell Commands ===${reset}"
  echo ""
  echo "${header}-- Git --${reset}"
  echo "  ${cmd}gdiff${reset}        git diff"
  echo "  ${cmd}gf${reset}           git fetch"
  echo "  ${cmd}gfo${reset}          git fetch origin"
  echo "  ${cmd}gfap${reset}         git fetch && git pull"
  echo "  ${cmd}gpull${reset}        git pull"
  echo "  ${cmd}gpush${reset}        git push"
  echo "  ${cmd}gr${reset}           git rebase"
  echo "  ${cmd}gl${reset}           git log (graph, last 20)"
  echo "  ${cmd}gcl${reset}          git clone"
  echo "  ${cmd}gcm${reset}          git commit -m"
  echo "  ${cmd}gaa${reset}          git add ."
  echo "  ${cmd}gst${reset}          git status"
  echo "  ${cmd}gco${reset}          git checkout"
  echo "  ${cmd}gcob${reset}         git checkout -b"
  echo "  ${cmd}gb${reset}           git branch"
  echo "  ${cmd}gbd${reset}          git branch -D"
  echo "  ${cmd}gss${reset}          git stash"
  echo "  ${cmd}gsp${reset}          git stash pop"
  echo "  ${cmd}grh${reset}          git reset --hard"
  echo "  ${cmd}grb${reset}          git rebranch <branch> <base>: recreate <branch> off an updated <base>"
  echo "  ${cmd}gblog${reset}        List recently checked-out branches (default 20)"
  echo ""
  echo "${header}-- AI (claude -p) --${reset}"
  echo "  ${cmd}gcai${reset}         Generate a commit message from staged diff, confirm before committing"
  echo "  ${cmd}ask${reset}          Ask Claude a one-off question; also works as a pipe target"
  echo "  ${cmd}greview${reset}      Review current branch diff vs base (default beta) for bugs"
  echo "  ${cmd}gprc${reset}         Push & open/edit a PR (default beta); optional Claude-drafted body (-a)"
  echo "  ${cmd}explain${reset}      Explain piped error/output: <cmd> 2>&1 | explain"
  echo ""
  echo "${header}-- Shell --${reset}"
  echo "  ${cmd}dot${reset}          Open the dotfiles control-center TUI"
  echo "  ${cmd}dotfiles${reset}     Open the TUI (alias of dot)"
  echo "  ${cmd}dotfiles pull${reset}  Pull latest dotfiles and reload"
  echo "  ${cmd}dotfiles help${reset}  Show this help menu"
  echo "  ${cmd}cls${reset}          Clear terminal"
  echo "  ${cmd}zedit${reset}        Edit aliases in nano"
  echo "  ${cmd}zrestart${reset}     Reload ~/.zshrc (soft)"
  echo "  ${cmd}restart${reset}      Restart the shell (exec zsh)"
  echo "  ${cmd}zhelp${reset}        Show this help menu"
  echo "  ${cmd}sim${reset}          Manage iOS/Android simulators"
  echo ""
}
