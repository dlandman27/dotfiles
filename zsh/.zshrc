# Aliases
source ~/dotfiles/zsh/aliases.zsh

# Prompt
source ~/dotfiles/zsh/prompt.zsh

# Node
export NODE_OPTIONS="--max-old-space-size=8192"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

# Machine-specific config (gitignored, never committed)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
