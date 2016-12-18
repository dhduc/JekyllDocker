#!/bin/bash

WEB='web'
GIT_REMOTE='git@github.com:dhduc/dhduc.github.io.git'
GIT_OPTIONS=''

ENDC=`tput setaf 7`
RED=`tput setaf 1`
GREEN=`tput setaf 2`

if [ -n "$1" ]; then
	GIT_REMOTE=$1
fi

echo 'Create and clone project to' $WEB 'folder'
if [ -d $WEB ]; then
	echo $RED 'NOTICE: Exist folder ' $WEB $ENDC
else
	git clone $GIT_OPTIONS $GIT_REMOTE $WEB	
	echo $GREEN 'Clone done to' $WEB 'folder' $ENDC
fi