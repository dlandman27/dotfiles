# avit — two-line with a clock on the right.
zstyle ':vcs_info:git:*' formats '%F{magenta}%b%f '
PROMPT=$'\n%F{blue}%~%f ${vcs_info_msg_0_}\n%(?.%F{green}.%F{red})❯%f '
RPROMPT='%F{242}%*%f'
