# agnoster-lite — powerline-style colored segments, no special font needed.
zstyle ':vcs_info:git:*' formats '%b'
PROMPT='%K{blue}%F{white} %~ %k%f%K{green}%F{black}${vcs_info_msg_0_:+  %F{black}${vcs_info_msg_0_} }%k%f '
