# arrow — exit-status-colored arrow.
zstyle ':vcs_info:git:*' formats '%F{242}(%b)%f '
PROMPT='%(?:%F{green}:%F{red})➜%f %F{cyan}%~%f ${vcs_info_msg_0_}'
