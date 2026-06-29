# minimal — cwd + branch, nothing else.
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f '
PROMPT='%F{green}%~%f ${vcs_info_msg_0_}%# '
