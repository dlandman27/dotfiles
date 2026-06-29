# ys — informative single line.
zstyle ':vcs_info:git:*' formats 'git:(%F{cyan}%b%f) '
PROMPT=$'%F{cyan}# %F{white}%n %F{cyan}@ %F{green}%m %F{cyan}in %F{yellow}%~ %f${vcs_info_msg_0_}\n$ '
