#!/usr/bin/bash

git pull
if [ "$(diff .bashrc ~/.bashrc)" ]
then
	cat .bashrc > ~/.bashrc
fi
