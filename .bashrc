#!/usr/bin/bash
######       Variables       ######

linqs="\[\033[38;2;244;66;178m\]"
end_c="\[\e[0m\]"
user="\[\033[38;2;160;209;242m\]"
signs="\[\033[38;2;160;241;146m\]"
host="\[\033[01;96m\]"
conti="\[\033[0;96m\]"
path="\[\033[0;32m\]"

bottomCharset="\342\224\224\342\224\200\342\224\200\342\225\274"
topCharset="\342\224\214\342\224\200"
crossCharset="\342\234\227"
dashCharset="\342\224\200"
gitStatus=""

######       Functions       ######

export hasRun=false

function setGitStatus {
	git_status=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
}

function psOne {
	c_status=$?
	r_jobs=$(jobs | wc -l)
	r_containers=$(docker ps -a 2>/dev/null | sed '1d' | wc -l)

	path_r=$(pwd | sed "s|$HOME|~|" | sed "s|$work|work|")
	host_r=$(hostname | cut -d "." -f1 )

	setGitStatus
	PS1="$linqs$topCharset$(if [[ $c_status != 0 ]]; then echo "[$user$crossCharset$linqs]$dashCharset"; fi)"
	PS1+="$(if [[ $r_jobs != 0 ]]; then echo "[$user$r_jobs$linqs]$dashCharset"; fi)"
	PS1+="[$user\u$signs@$host\h$linqs]$dashCharset[$path$path_r$linqs]"
	PS1+="$(if [[ "$git_status" ]]; then echo "$dashCharset[$host$git_status$linqs]"; fi)"
	PS1+="$(if [[ $r_containers != 0 ]]; then echo "$dashCharset<$conti$r_containers$linqs>"; fi)"
	PS1+="\n$bottomCharset $signs\$ $end_c"
}

function findFunction {
	THIS_FILE="$HOME/.$(echo $SHELL | awk -F "/" '{print $NF}')rc"
	cat $THIS_FILE | grep "function" | awk '{print $1" "$2}' | grep -v "cat \$THIS_FILE" | grep -o "$1"
}

function exportrc { # 1. param: Name; 2. param: NewValue
	THIS_FILE="$HOME/.$(echo $SHELL | awk -F "/" '{print $NF}')rc"
	VAR_LINE=$(cat $THIS_FILE | grep -n -m 1 $1 | sed 's/\([0-9]*\).*/\1/')
	FILE_LENGTH=$(($(cat $THIS_FILE | wc -l)+1))
	TMP_FILE="$HOME/.rcCopyTemp"

	awk "NR >= 0 && NR < $VAR_LINE" $THIS_FILE > $TMP_FILE

	if [ ! -z "$(findFunction "$2")" ]
	then
		echo $1=$($(findFunction "$2") "$3") >> $TMP_FILE
	else
		echo $1'='$2 >> $TMP_FILE
	fi

	awk "NR > $VAR_LINE && NR < $FILE_LENGTH" $THIS_FILE >> $TMP_FILE

	cat $TMP_FILE > $THIS_FILE
	source $THIS_FILE
}

function red {
	echo '"\[\033[38;2;255;'$1';0m\]"'
}

function termColor {
	MYVAR="$1"
	HEX_BLUE=${MYVAR:4:2}
	HEX_GREEN=${MYVAR:2:2}
	HEX_RED=${MYVAR:0:2}
	echo '"\[\033[38;2;'$((16#$HEX_RED))';'$((16#$HEX_GREEN))';'$((16#$HEX_BLUE))'m\]"'
}

function vars {
	THIS_FILE="$HOME/.$(echo $SHELL | awk -F "/" '{print $NF}')rc"
	START=$(($(cat $THIS_FILE | grep -n -m 1 "######       Variables       ######"| sed 's/\([0-9]*\).*/\1/')+2))
	END=$(($(cat $THIS_FILE | grep -n -m 1 "######       Functions       ######"| sed 's/\([0-9]*\).*/\1/')-2))

	awk "NR >= $START && NR < $END" $THIS_FILE
}

PROMPT_COMMAND='psOne'

######      Alias Space      ######

alias ll="ls -laG"
alias sus="source $HOME/.bashrc"
alias launch="/mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe $PWD"
alias rc="cat ~/.bashrc"
alias crc="/mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe ~/.bashrc"
