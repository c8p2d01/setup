#!/usr/bin/bash
chmod 777 $HOME/.bashrc
cd $PWD/setup && git pull
OS=$(uname -s)

if [ "$(diff .bashrc ~/.bashrc)" ]
then
	if [ "$OS" == "Darwin" ]
	then
		sed 's/.* #WIN//' .bashrc > ~/.bashrc
	else
		sed 's/.* #MAC//' .bashrc > ~/.bashrc
	fi
fi
