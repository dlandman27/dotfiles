# jonathan — branch + clock on the right, clean left.
zstyle ':vcs_info:git:*' formats '%F{yellow}%b%f'
PROMPT='%F{blue}%~%f %# '
RPROMPT='${vcs_info_msg_0_} %F{242}%*%f'
