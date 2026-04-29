# Aliases
source ~/dotfiles/zsh/aliases.zsh

# Prompt
source ~/dotfiles/zsh/prompt.zsh

# Dotfiles bin
export PATH="$PATH:$HOME/dotfiles/bin"

# Android
export PATH="$PATH:$HOME/Library/Android/sdk/emulator"

# Node
export NODE_OPTIONS="--max-old-space-size=8192"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

# Local zsh files (gitignored, never committed)
for f in ~/dotfiles/zsh/*.local.zsh; do [ -f "$f" ] && source "$f"; done

# Machine-specific config (gitignored, never committed)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
