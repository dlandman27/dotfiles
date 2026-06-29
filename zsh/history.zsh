# History — persistent, shared across sessions, de-duplicated.
HISTFILE=~/.zsh_history
HISTSIZE=50000           # lines kept in memory for the current session
SAVEHIST=50000           # lines persisted to $HISTFILE

setopt EXTENDED_HISTORY      # record timestamp + duration for each command
setopt HIST_IGNORE_ALL_DUPS  # drop older duplicates of a repeated command
setopt HIST_IGNORE_SPACE     # don't record commands prefixed with a space
setopt HIST_REDUCE_BLANKS    # collapse superfluous whitespace
setopt HIST_VERIFY           # show, don't immediately run, a !history expansion

# Share history live across open shells (toggleable via `dot`, default on).
: ${DOTFILES_HISTORY_SHARE:=1}
[[ "$DOTFILES_HISTORY_SHARE" == 1 ]] && setopt SHARE_HISTORY
