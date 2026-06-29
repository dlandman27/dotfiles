# kphoen — single-line "user at host in path on branch".
zstyle ':vcs_info:git:*' formats ' on %F{red}%b%f'
PROMPT=$'%F{green}%n%f at %F{yellow}%m%f in %F{cyan}%~%f${vcs_info_msg_0_}\n$ '
