#!/bin/bash
echo 'starting'

PATHNAME_CONFIG=/etc/nginx.conf
PATHNAME_OPTIONS=/data/options.json

function configStart() {
    PORT=$(jq --raw-output '.port' $PATHNAME_OPTIONS)
    echo "
daemon off;
error_log stderr;
pid /var/run/nginx.pid;

events {
	worker_connections 1024;
}

http {
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        ''      close;
    }

    access_log /share/port/access.log;

    server {
        listen $PORT default_server;
        listen [::]:$PORT default_server;

" > $PATHNAME_CONFIG
}

function configSite() {
    echo "config size: name=$1 host=$2 port=$3 path=$4"
    name=${1:-/}  
    host=${2:-127.0.0.1}  
    port=${3:-0}  
    path=${4:-/}  
    echo "
        location $name {
            proxy_pass http://${host}:${port}${path};
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection \"upgrade\";
        }
" >> $PATHNAME_CONFIG
}

function configSites() {
    echo '-config sites-'
    for i in $(jq --raw-output 'range(.sites|length)' $PATHNAME_OPTIONS); 
    do 
        ARGS=$(jq --raw-output ".sites[$i]|.name, .host, .port, .path" $PATHNAME_OPTIONS | xargs)
        configSite $ARGS
    done  
}

function configEnd() {
    echo "
    }
}
" >> $PATHNAME_CONFIG
}

configStart
configSites
configEnd
echo '-------------'
cat $PATHNAME_CONFIG
echo '-------------'
nginx -c $PATHNAME_CONFIG