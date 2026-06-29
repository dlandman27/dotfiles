# Active settings (theme choice + module toggles) — gitignored, written by `dot`.
# Sourced first so the theme loader and plugin toggles below can read it.
[ -f ~/dotfiles/zsh/settings.local.zsh ] && source ~/dotfiles/zsh/settings.local.zsh

# History
source ~/dotfiles/zsh/history.zsh

# Aliases
source ~/dotfiles/zsh/aliases.zsh

# AI helpers (gcai, ask, greview, explain)
source ~/dotfiles/zsh/ai.zsh

# Prompt theme (reads $DOTFILES_THEME; pick one with `dot`)
source ~/dotfiles/zsh/theme.zsh

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

# zsh plugins (brew bundle), toggleable via settings (default on). Autosuggestions
# first; syntax-highlighting MUST be sourced last — it wraps the line editor and
# expects all widgets to exist.
: ${DOTFILES_AUTOSUGGEST:=1}
: ${DOTFILES_HIGHLIGHT:=1}
# brew on mac/linuxbrew, then common Linux package paths.
for ZSH_PLUGINS in "$(brew --prefix 2>/dev/null)/share" /usr/share /usr/local/share; do
  [ -d "$ZSH_PLUGINS" ] || continue
  [[ "$DOTFILES_AUTOSUGGEST" == 1 ]] && [ -f "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ "$DOTFILES_HIGHLIGHT" == 1 ]] && [ -f "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
done
