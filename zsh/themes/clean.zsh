# clean — two-line, plain.
zstyle ':vcs_info:git:*' formats '%F{green}%b%f '
PROMPT=$'%F{white}%~%f ${vcs_info_msg_0_}\n%(?.%F{green}.%F{red})$%f '
