# nebirhos — user@host:path with angle-quoted branch.
zstyle ':vcs_info:git:*' formats '%F{red}‹%b›%f '
PROMPT='%F{cyan}%n%f@%F{green}%m%f:%F{yellow}%~%f ${vcs_info_msg_0_}%# '
