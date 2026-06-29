# History
source ~/dotfiles/zsh/history.zsh

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
for f in ~/dotfiles/zsh/*.local.zsh(N); do [ -f "$f" ] && source "$f"; done

# Machine-specific config (gitignored, never committed)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# zsh plugins (brew bundle). Autosuggestions first; syntax-highlighting MUST be
# sourced last — it wraps the line editor and expects all widgets to exist.
ZSH_PLUGINS="$(brew --prefix 2>/dev/null)/share"
[ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
  && source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
  && source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
