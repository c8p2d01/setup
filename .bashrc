#!/usr/bin/bash

export SHELL=/bin/bash

OS=$(uname -s)

######       Variables       ######

linqs="\[\033[38;2;254;220;186m\]"
end_c="\[\e[0m\]"
user="\[\033[38;2;68;68;238m\]"
signs="\[\033[38;2;238;51;238m\]"
branch="\[\033[38;2;255;255;170m\]"
host="\[\033[0;32m\]"
conti="\[\033[0;96m\]"
path="\[\033[38;2;170;255;170m\]"

######       Functions       ######

bottomCharset="\342\224\224\342\224\200\342\224\200\342\225\274"
topCharset="\342\224\214\342\224\200"
crossCharset="\342\234\227"
dashCharset="\342\224\200"
gitStatus=""

export hasRun=false
THIS_FILE="$HOME/.$(echo $SHELL | awk -F "/" '{print $NF}')rc"

setGitStatus () {
	git_status=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
}

psOne () {
	c_status=$?
	r_jobs=$(jobs | wc -l | tr -d ' ')
	r_containers=$(docker ps -a 2>/dev/null | sed '1d' | wc -l | tr -d ' ')

	path_r=$(pwd | sed "s|$HOME|~|")
	host_r=$(hostname | cut -d "." -f1 )

	setGitStatus
	PS1="$linqs$topCharset$(if [[ $c_status != 0 ]]; then echo "[$user$crossCharset$linqs]$dashCharset"; fi)"
	PS1+="$(if [[ $r_jobs != 0 ]]; then echo "[$user$r_jobs$linqs]$dashCharset"; fi)"
	PS1+="[$user\u$signs@$host\h$linqs]$dashCharset[$path$path_r$linqs]"
	PS1+="$(if [[ "$git_status" ]]; then echo "$dashCharset[$repo$git_status$linqs]"; fi)"
	PS1+="$(if [[ $r_containers != 0 ]]; then echo "$dashCharset<$conti$r_containers$linqs>"; fi)"
	PS1+="\n$bottomCharset $signs\$ $end_c"
}

findFunction () {
	cat $THIS_FILE | grep "function" | awk '{print $1" "$2}' | grep -v "cat \$THIS_FILE" | grep -o "$1"
}

function exportrc { 	# change the value of a variable in this script. 1. param: Name; 2. param: NewValue
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

function red {		# return a string that colors the terminal red
	echo '"\[\033[38;2;255;0;0m\]"'
}

function termColor {	# return a sequence representing the RGB as Terminal escapement. param 1: RGB as hex
	MYVAR="$1"
	if [[ $(echo -n $MYVAR | wc -c | tr -d ' ') != 6 ]];
	then
		echo '"\[\033[38;2;255;255;255;64m\]"'
	else
		HEX_BLUE=${MYVAR:4:2}
		HEX_GREEN=${MYVAR:2:2}
		HEX_RED=${MYVAR:0:2}
		echo '"\[\033[38;2;'$((16#$HEX_RED))';'$((16#$HEX_GREEN))';'$((16#$HEX_BLUE))'m\]"'
	fi
}

function vars {		# print important variables 
	START=$(($(cat $THIS_FILE | grep -n -m 1 "######       Variables       ######"| sed 's/\([0-9]*\).*/\1/')+2))
	END=$(($(cat $THIS_FILE | grep -n -m 1 "######       Functions       ######"| sed 's/\([0-9]*\).*/\1/')-2))

	awk "NR >= $START && NR < $END" $THIS_FILE
}

function funcs {	# return all user functions
	cat $THIS_FILE | grep "function" | grep -v "cat \$THIS_FILE"
}

PROMPT_COMMAND='psOne'

######      Alias Space      ######

alias ll="ls -laG"
alias sus="source $HOME/.bashrc"
alias launch="/mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe $PWD" #WIN
alias launch="open -n /Applications/Visual\ Studio\ Code.app $PWD" #MAC
alias rc="cat ~/.bashrc"
alias crc="/mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe ~/.bashrc" #WIN
alias crc="open -n /Applications/Visual\ Studio\ Code.app --args $HOME/.bashrc" #MAC
alias stats="git status"

alias francinette="sh $HOME/francinette/tester.sh"

alias paco="sh $HOME/francinette/tester.sh"

alias pain='osascript -e "tell application \"System Events\""  -e "tell appearance preferences" -e "repeat 69420 times" -e "if dark mode is false then" -e "set dark mode to true" -e "else" -e "set dark mode to false" -e "end if" -e "delay 0.2" -e "end repeat" -e "end tell" -e "end tell" &' #MAC
alias meds='pkill -9 osascript' #MAC
alias lock="osascript -e 'tell application id \"com.apple.ScreenSaver.Engine\" to launch'" #MAC
alias rebrew="rm -rf $HOME/.brew && git clone --depth=1 https://github.com/Homebrew/brew $HOME/goinfre/.brew && source $HOME/.bashrc && brew update && export HOMEBREW_CASK_OPTS='--appdir=~/goinfre/Applications' && export HOMEBREW_MAKE_JOBS=4" #MAC
alias copy="echo ' use > | pbcopy< to store results in Zwischenablage'" #MAC
export PATH=$HOME/goinfre/.brew/bin:$PATH #MAC