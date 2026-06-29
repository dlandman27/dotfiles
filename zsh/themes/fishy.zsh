# fishy — fish-like, last two path segments.
zstyle ':vcs_info:git:*' formats '%F{242}(%b)%f '
PROMPT='%F{cyan}%2~%f ${vcs_info_msg_0_}%(?.%F{green}.%F{red})▶%f '
