#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

link() {
  local src="$1"
  local dst="$2"
  if [ -L "$dst" ]; then
    echo "already linked: $dst"
  elif [ -f "$dst" ]; then
    echo "backing up: $dst → $dst.bak"
    mv "$dst" "$dst.bak"
    ln -s "$src" "$dst"
    echo "linked: $dst"
  else
    ln -s "$src" "$dst"
    echo "linked: $dst"
  fi
}

link "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
link "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"

echo ""
echo "Done. Run 'source ~/.zshrc' to reload."
