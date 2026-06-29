# classic — the original dotfiles prompt: user@host, cwd, branch.
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b)%f '
PROMPT='%F{cyan}%n@%m%f %F{green}%~%f ${vcs_info_msg_0_}%# '
