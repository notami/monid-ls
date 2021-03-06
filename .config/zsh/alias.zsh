# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#######################
# #fix obvious typo's #
#######################
alias cd..='cd ..'
alias sl="ls"

##############################################################################
# ## Colorize the grep command output for ease of use (good for log files)## #
##############################################################################
alias pdw="pwd"
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias tldr="tldr -t ocean"

####################
# #readable output #
####################
alias df='df -h'
alias merge="xrdb -merge ~/.config/Xresources"

#########
# mount #
#########
alias mntphone="sudo simple-mtpfs -o allow_other --device 1 /mnt/usb"

##########
# search #
##########

alias so='googler -j -w stackoverflow.com | xsel'

#######
# FUN #
#######

alias fishy="asciiquarium"

###################
# ### general ### #
###################
alias cls="clear"
alias la="ls -alG" --color
alias uls="cd /usr/local/share"
alias l.="ls -A | egrep '^\.'"
alias xpp="xprop | grep -i 'class'"
alias hst="history 1"
################################
# ### config - (git alias) ### #
################################
alias cs="config status"
alias ca="config add"
alias cc="config commit"
alias ccm="config commit -m"
alias cp="config push"

################################
# ###      git alias       ### #
################################
alias gis="git status"
alias gia="git add"
alias gic="git commit"
alias gicm="git commit -m"
alias gip="git push"

####################
# Calling All Apps #
####################
## alias cat="bat"
alias mail="neomutt"
alias music="ncmpcpp"
alias clock="ncmpcpp -s clock"
alias viz="ncmpcpp -s visualizer"
alias nb="newsboat"
alias pp1="pipes"
alias pp3="pipes -t 3 -p 3 -f 30"
alias wall='wal -i ~/pictures/favs'
alias srr='sr -elvi | less'
alias hsw='history | grep --color=auto wal -i'
alias du="ncdu --color dark -x --exclude .git --exclude node_modules"
alias dus="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
alias mlv='/usr/bin/mullvad-vpn &; disown'
alias wfz='wpg -s $(wpg -l | fzf)'
alias rcp="rofi -modi 'clipboard:greenclip print' -show clipboard -run-command '{cmd}"
alias fcp="fzf-greenclip"
alias gcd="nohup greenclip daemon > /dev/null 2>&1 &"
alias tw3="torsocks w3m"

################
# Some aliases #
################
alias p="sudo pacman"
alias SS="sudo systemctl"
alias vi="nvim"
alias vim="nvim"
alias sv="sudo nvim"
alias sr="sudo ranger"
alias ka="killall"
alias g="git"
alias trem="transmission-remote"
alias mkd="mkdir -pv"
alias rz="source ~/.config/zsh/.zshrc"
alias ref="shortcuts.sh && source ~/.zshrc" # Refresh shortcuts manually and reload zshrc
alias pi="bash ~/.larbs/wizard/wizard.sh"

###############
# ### ssh ### #
###############
alias ssh.f="ssh notami@notami.xyz"
alias ssh.d="ssh notami@dbsaurer.com"
alias ssh.tv="ssh 192.168.1.22"
alias ssh.mo="ssh 192.168.1.103"
alias ssh.nid="ssh 192.168.1.37"
alias ssh.kt="ssh 192.168.1.47"

####################
# ### commands ### #
####################
alias scrimp="scrot -q 85 -d 5 screenshot.png && gimp screenshot.png &"
alias rebar="pkill -USR1 polybar"
alias usbbye='udisksctl unmount -b /dev/sdc1'
alias preview="fzf --preview 'bat --color 'always' {}'"
alias m-m="make && sudo make install"

##################
# ### iohyve ### #
##################
alias io="iohyve"

################
# ### tmux ### #
###############
alias tmn="tmux new -s"
alias tma="tmux a -t"
alias tms="tmux list-sessions"
alias tmks="tmux kill-session -t"
alias tmrs="tmux source-file ~/.tmux/.tmux.rsync.conf"
alias restore="~/.local/bin/tmux-s.sh restore"
alias daily="tma daily"

#################
# ### rsync ### #
#################
alias rsdbsd="rsync -auvzhe ssh --progress notami@dbsaurer.com:/var/www/html/ /mnt/Data/Docs/Client/DBS/dbsaurer.com/BU-DBS/LocalMirror-DBS/"
# alias rsdbsf="rsync -ruvzhe ssh --progress "/home/notami/Documents/MyDocuments/Client/DBS/" "/mnt/Data/Docs/Client/DBS/""
alias rsmhd="rsync -auvzhe ssh --progress notami@dbsaurer.com:/var/www/miraclesupholstery.com/html/ /mnt/Data/Docs/Client/MiraclesHappen/miraclesupholstery.com/BU-MH/LocalMirror-MH/"
# alias rsmhf="rsync -ruvzhe ssh --progress "/home/notami/Documents/MyDocuments/Client/MiraclesHappen/" "/mnt/Data/Docs/Client/MiraclesHappen/""
alias rsold="rsync -auvzhe ssh --progress notami@dbsaurer.com:/var/www/olnb.org/html/ /mnt/Data/Docs/Client/One\ Love\ No\ Boundaries/olnb.org/BU-OLNB/LocalMirror-OLNB/"
# alias rsolf="rsync -ruvzhe ssh --progress "/home/notami/Documents/MyDocuments/Client/One Love No Boundaries/" "/mnt/Data/Docs/Client/One Love No Boundaries/""
alias rsnot="rsync -avz -e 'ssh -i /home/notami/.ssh/nid-rsync' --progress –delete --exclude={/refDesk/,/tv-home/,index.html,indexSam.html,ex.txt,Vim-quickRef.pdf} /mnt/www/nginx/ notami@dbsaurer.com:/var/www/notami.us/html/"
alias rshome="rsync -aP --exclude-from=/var/tmp/ignorelist -e ssh /home/$USER/ notami@notami.xyz:/mnt/vol2/Data/Archive/monid"
alias rspix="rsync -av -progress /mnt/Data/Docs/tmp/favs/* /home/notami/Pictures/favs/ && diff -rq /mnt/Data/Docs/tmp/favs ~/Pictures/favs"
alias savehome="~/.local/src/rclone_jobber/monid_backup.sh"
alias rsns="rsync -auvzhe ssh --progress notami@dbsaurer.com:/var/www/medinahypnotherapy.com/html/ /mnt/Data/Docs/Client/Nina/LocalMirror-MH/"

####################################
# Aliases for software managment #
####################################
# pacman or pm
alias pmsyu="sudo pacman -Syu --color=auto"
alias pacman="sudo pacman --color=auto"
alias update='ckre && pacman -Syu && ckre && echo Update Complete! | figlet'
# pacaur or pc
alias pcsyu="pacaur -Syu"
alias pcsyua="yaourt -Syu --aur --noconfirm"
# packer or pk
alias pks="packer -S"
alias pksn="packer -S --noconfirm --noedit"
alias pksyu="packer -Syu --noconfirm --noedit"
alias tvstart="systemctl start teamviewerd.service"
alias tvstop="systemctl stop teamviewerd.service"
alias ckre="sudo python2.7 ~/.local/bin/checkrestart.py"
alias reflectmirror="sudo reflector --latest 50 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"

#######################
# System Maintainence #
#######################
alias muttwizard="~/.config/mutt/mutt-wizard.sh"
alias progs="(pacman -Qet && pacman -Qm) | sort -u" # List programs I've installed
alias orphans="pacman -Qdt" # List orphan programs
alias sdn="sudo shutdown now"
alias psref="gpg-connect-agent RELOADAGENT /bye" # Refresh gpg
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias clear_history='echo "" > ~/.zsh_history & exec $SHELL -l'
alias refmir20="sudo reflector --verbose --latest 20 --sort rate --save /etc/pacman.d/mirrorlist"
alias lsblk="lsblk -o NAME,MAJ:MIN,RM,SIZE,TYPE,LABEL,FSTYPE,UUID,MOUNTPOINT"

#####################
# # show log output #
#####################
alias syslog="journalctl -p 3 -xb"
alias pth='echo $PATH | tr ":" "\n" | nl'

######################
# CD Rip-MP3 Convert #
######################
alias cdck="cdparanoia -vsQ"
alias cdrip="cdparanoia -BZ"
alias cdrip+="cdparanoia -B"
alias mp3con="for t in track{01..21}*.wav; do lame $t; done"
alias flac2mp3="for file in *.flac; do ffmpeg -i $file -q:a 0 ${file:r}.mp3; done"

#####################
# You Tube Download #
#####################
alias ytdl="youtube-dl -f best"
alias ytdla="youtube-dl -x --audio-format mp3"
alias ytdlp="youtube-dl -o --proxy socks://10.8.0.1:1080 "
alias ytdlap="youtube-dl -x --audio-format mp3 -i -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

##############
# TPB SEARCH #
##############
alias tpbs="clear && figlet -c TPB Search && ~/.scripts/tpb"

####################
# Search arch wiki #
####################
alias aw='arch-wiki'

#######
# UFW #
#######
alias ufw='sudo ufw'
alias ufwsv='sudo ufw status verbose'
alias ufwsn='sudo ufw status numbered'

################
# GLOBAL ALIAS #
################

# http://www.zzapper.co.uk/zshtips.html
alias -g ND='*(/om[1])'        # newest directory
alias -g NF='*(.om[1])'        # newest file
alias -g NO='&>|/dev/null'
alias -g P='2>&1 | $PAGER'
alias -g VV='| vim -R -'
alias -g L='| less'
alias -g M='| most'
alias -g C='| wc -l'
alias -g H='| head'
alias -g W='wal -i ~/Pictures/favs'
alias -g T='| tail'
alias -g G='| grep --color=auto'
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
