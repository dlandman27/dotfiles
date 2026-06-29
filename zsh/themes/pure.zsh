# pure — minimal two-line, magenta prompt char.
zstyle ':vcs_info:git:*' formats '%F{242}%b%f '
PROMPT=$'\n%F{blue}%~%f ${vcs_info_msg_0_}\n%(?.%F{magenta}.%F{red})❯%f '
