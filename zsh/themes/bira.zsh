# bira — two-line, user@host on top.
zstyle ':vcs_info:git:*' formats '%F{yellow}git:(%b)%f '
PROMPT=$'%F{green}%n@%m%f:%F{blue}%~%f ${vcs_info_msg_0_}\n%F{cyan}›%f '
