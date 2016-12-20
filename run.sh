#!/bin/bash

WEB='web'
PROJECT='jekyll.local'
PORT='4000'
APPNAME='jekyll/jekyll'
VHOST='jekyll.conf'
IP='127.0.0.1'

ENDC=`tput setaf 7`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
NORMAL=`tput sgr0`
BOLD=`tput bold`

echo "Start docker services"
docker-compose up -d

if [ -n "$1" ]; then
	PROJECT=$1
fi

jekyll_conf() {
	JEKYLL_ID=$(docker ps | grep $APPNAME | awk '{print $1}')
	if [ -z "$JEKYLL_ID" ]; then
		echo $RED ERROR: Container \"$PROJECT\" could not be started. $ENDC
		exit 1
	fi

	IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $JEKYLL_ID)
	if [ -z "$IP" ]; then
		echo $RED ERROR: Could not find the IP address of container \"$PROJECT\". $ENDC
		exit 1
	fi

	CONDITION="grep -q '"$PROJECT"' /etc/hosts"
	if eval $CONDITION; then
		CMD="sudo sed -i -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +"$PROJECT")/"$IP" "$PROJECT"/\" /etc/hosts";
	else
		CMD="sudo sed -i '\$a\\\\n# Added automatically by run.sh\n"$IP" "$PROJECT"\n' /etc/hosts";
	fi

	eval $CMD
	if [ "$?" -ne 0 ]; then
		echo $RED ERROR: Could not update $PROJECT to hosts file. $ENDC
		exit 1
	fi

	echo $GREEN Project http://$PROJECT:$PORT loaded at $IP $ENDC
}

nginx_conf() {
	echo 'Setup Nginx virtual host'

	if [ -s nginx.conf ]; then
		rm nginx.conf
	fi
	cp nginx.conf.sample nginx.conf
	sed -i "s/your_domain/${PROJECT}/g" nginx.conf
	if [ -s /etc/nginx/conf.d/$VHOST ]; then
		sudo rm -rf /etc/nginx/conf.d/$VHOST
	fi
	sudo cp nginx.conf /etc/nginx/conf.d/$VHOST	

	CONDITION="grep -q '"$PROJECT"' /etc/hosts"
	if eval $CONDITION; then
		CMD="sudo sed -i -r \"s/^ *[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+( +"$PROJECT")/"$IP" "$PROJECT"/\" /etc/hosts";
	else
		CMD="sudo sed -i '\$a\\\\n# Added automatically by run.sh\n"$IP" "$PROJECT"\n' /etc/hosts";
	fi
		
	eval $CMD
	if [ "$?" -ne 0 ]; then
		echo $RED ERROR: Could not update $PROJECT to hosts file. $ENDC
		exit 1
	fi

	sudo service nginx restart

	echo $GREEN Project http://$PROJECT loaded at $IP $ENDC
}

nginx_conf
