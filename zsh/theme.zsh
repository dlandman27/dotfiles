# Prompt theme loader.
#
# The active theme name lives in the gitignored zsh/settings.local.zsh as
# DOTFILES_THEME (the `dot` TUI writes it). Theme files live in zsh/themes/
# (committed) and zsh/themes/local/ (gitignored, AI-generated). Each theme file
# is a self-contained snippet that sets PROMPT (and optionally RPROMPT) and may
# override the vcs_info git format — it should NOT call vcs_info or set precmd;
# that's handled here, once.

autoload -Uz vcs_info
setopt prompt_subst
precmd() { vcs_info }

: ${DOTFILES_THEME:=robbyrussell}

# Defaults a theme can override.
zstyle ':vcs_info:git:*' formats '(%b) '
RPROMPT=''

# local/ first so a same-named local theme overrides a built-in one.
for _d in ~/dotfiles/zsh/themes/local ~/dotfiles/zsh/themes; do
  if [ -f "$_d/$DOTFILES_THEME.zsh" ]; then
    source "$_d/$DOTFILES_THEME.zsh"
    break
  fi
done
unset _d
