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
link "$DOTFILES/git/.gitignore_global" "$HOME/.gitignore_global"

# Apple Terminal profiles: import any exported *.terminal file from terminal/
# and make the first one Terminal's default + startup profile. macOS only.
# `open` registers a profile under Settings → Profiles; `defaults` then makes
# it the default. (Set DOTFILES_SKIP_TERMINAL=1 to skip — the test suite does,
# so `make test` doesn't pop open Terminal windows.)
if [ "$(uname)" = "Darwin" ] && [ -z "${DOTFILES_SKIP_TERMINAL:-}" ]; then
  default_profile=""
  for profile in "$DOTFILES"/terminal/*.terminal; do
    [ -e "$profile" ] || continue
    name="$(basename "$profile" .terminal)"
    if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -qw "$name"; then
      echo "Terminal profile already imported: $name"
    else
      open "$profile" && echo "imported Terminal profile: $name"
    fi
    if [ -z "$default_profile" ]; then
      defaults write com.apple.Terminal "Default Window Settings" -string "$name"
      defaults write com.apple.Terminal "Startup Window Settings" -string "$name"
      default_profile="$name"
    fi
  done
  [ -n "$default_profile" ] && \
    echo "set default Terminal profile: $default_profile (restart Terminal to apply)"
fi

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
