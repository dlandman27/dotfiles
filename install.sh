#!/usr/bin/env bash
set -e

# Resolve the repo root from this script's location, so it works wherever
# the repo is cloned (not just ~/dotfiles).
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Warn about tools the configs expect (install them with: brew bundle).
missing=()
for tool in claude gh gum rbenv; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo ""
  echo "Missing tools: ${missing[*]}"
  echo "Install them with: brew bundle --file=\"$DOTFILES/Brewfile\""
fi

echo ""
echo "Done. Run 'source ~/.zshrc' to reload."
