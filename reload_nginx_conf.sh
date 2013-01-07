#!/usr/bin/env bash 

sudo nginx -t -c /etc/nginx/nginx.conf
echo "Do you wish to relaunch nginx?"
select yn in "Yes" "No"; do
        case $yn in
           Yes ) sudo kill -HUP $( cat /var/run/nginx.pid ); break;;
           No ) exit;;
        esac
done
