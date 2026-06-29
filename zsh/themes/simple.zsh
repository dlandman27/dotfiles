# simple — basename + branch.
zstyle ':vcs_info:git:*' formats '%F{green}%b%f '
PROMPT='%F{blue}%c%f ${vcs_info_msg_0_}%# '
