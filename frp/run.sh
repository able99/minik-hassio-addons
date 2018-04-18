#!/bin/bash
set -e

PATHNAME_OPTIONS=/data/options.json
FRP_PATH=/frp
FRPC_CONF=$FRP_PATH/frpc.ini

CLIENT_NAME=$(jq --raw-output '.clinet_name' $PATHNAME_OPTIONS)
SERVER_IP=$(jq --raw-output '.server_ip' $PATHNAME_OPTIONS)
SERVER_PORT=$(jq --raw-output '.server_port' $PATHNAME_OPTIONS)
AUTH_TOKEN=$(jq --raw-output '.auth_token // empty' $PATHNAME_OPTIONS)


function configGlobal() {
  echo '-config global-'
  echo "
[common]
server_addr = ${SERVER_IP:-0.0.0.0}
server_port = ${SERVER_PORT:-7000}
privilege_token = ${AUTH_TOKEN}
user = ${CLIENT_NAME:-minik}
" > $FRPC_CONF
}

function configItem() {
  echo "config item: name=$1 type=$2 local_port=$3 remote_port=$4"
  echo "
[$1]
  type = $2
  local_ip = 127.0.0.1
  local_port = $3
  remote_port = $4
" >> $FRPC_CONF
}

function configItems() {
  echo '-config items-'
  for i in $(jq --raw-output 'range(.proxys|length)' $PATHNAME_OPTIONS); 
  do 
      ARGS=$(jq --raw-output ".proxys[$i]|.name, .type, .local_port, .remote_port" $PATHNAME_OPTIONS | xargs)
      configItem $ARGS
  done  
}


echo 'Start FRPC'
configGlobal
configItems
echo '----------'
cat ${FRPC_CONF}
echo '----------'
exec $FRP_PATH/frpc -c $FRPC_CONF
