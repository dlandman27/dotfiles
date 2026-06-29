# sunset — warm gradient prompt (gold → orange → coral → pink)
zstyle ':vcs_info:git:*' formats ' %F{211}on %F{213}%b%f'

PROMPT='%F{220}%n%f%F{208}@%f%F{214}%m%f %F{208}in %F{215}%~%f${vcs_info_msg_0_}
%(?.%F{215}❯.%F{203}❯)%f '
RPROMPT='%F{209}%*%f'
