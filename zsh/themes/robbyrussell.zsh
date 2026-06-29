# robbyrussell — the oh-my-zsh default look.
zstyle ':vcs_info:git:*' formats '%F{red}git:(%F{yellow}%b%F{red})%f '
PROMPT='%(?:%F{green}➜:%F{red}➜)%f %F{cyan}%c%f ${vcs_info_msg_0_}'
