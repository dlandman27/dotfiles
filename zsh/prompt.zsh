autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b) '
setopt prompt_subst
PROMPT='%F{cyan}%n@%m%f %F{green}%~%f %F{yellow}${vcs_info_msg_0_}%f %# '
