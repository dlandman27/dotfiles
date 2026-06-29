# dallas — verbose "user at host in path".
zstyle ':vcs_info:git:*' formats 'on %F{blue}%b%f '
PROMPT=$'%F{cyan}%n%f at %F{yellow}%m%f in %F{green}%~%f ${vcs_info_msg_0_}\n$ '
