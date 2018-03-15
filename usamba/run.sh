#!/bin/bash
echo starting

set -e

CONFIG_PATH=/data/options.json

WORKGROUP=$(jq --raw-output '.workgroup' $CONFIG_PATH)
NAME=$(jq --raw-output '.name' $CONFIG_PATH)
GUEST=$(jq --raw-output '.guest' $CONFIG_PATH)
USERNAME=$(jq --raw-output '.username // empty' $CONFIG_PATH)
PASSWORD=$(jq --raw-output '.password // empty' $CONFIG_PATH)
INTERFACE=$(jq --raw-output '.interface // empty' $CONFIG_PATH)
MAP_HASSIO=$(jq --raw-output '.hassio' $CONFIG_PATH)
MAP_DATA=$(jq --raw-output '.data' $CONFIG_PATH)
MAP_USER=$(jq --raw-output '.user' $CONFIG_PATH)
MAP_TMP=$(jq --raw-output '.tmp' $CONFIG_PATH)

function write_config() {
    echo "do write_config $1 $2 $3 $4 $5"
    if [ "$5" == "guest" ]; then
        echo "
[$1]
   browseable = $3
   writeable = $4
   path = $2

   guest ok = yes
   guest only = yes
   public = yes
" >> /etc/smb.conf
    elif [ "$2" == "user" ]; then
        echo "
[$1]
   browseable = $3
   writeable = $4
   path = $2

   valid users = $USERNAME
   force user = root
   force group = root
" >> /etc/smb.conf
   fi
}

echo 'common config' 
##
# common config
if [ -n "$USERNAME" ]; then
    addgroup -g 1000 "$USERNAME"
    adduser -D -H -G "$USERNAME" -s /bin/false -u 1000 "$USERNAME"
    echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/smb.conf "$USERNAME"
fi

sed -i "s/%%WORKGROUP%%/$WORKGROUP/g" /etc/smb.conf
sed -i "s/%%NAME%%/$NAME/g" /etc/smb.conf
sed -i "s/%%INTERFACE%%/$INTERFACE/g" /etc/smb.conf

echo 'section config'
##
# share section
write_config config /config yes yes $MAP_HASSIO 
write_config addons /addons yes yes $MAP_HASSIO 
write_config ssl /ssl yes yes $MAP_HASSIO 
write_config backup /backup yes yes $MAP_HASSIO 
write_config data /share/data yes yes $MAP_DATA 
write_config user /share/data no yes $MAP_USER
write_config tmp /share/tmp no yes $MAP_TMP

##
# start
echo '/etc/smb.conf'
cat /etc/smb.conf
echo '------------'

nmbd -F -S -s /etc/smb.conf &
NMBD_PID=$!
smbd -F -S -s /etc/smb.conf &
SMBD_PID=$!

# Register stop
function stop_samba() {
    kill -15 "$NMBD_PID"
    kill -15 "$SMBD_PID"
    wait "$SMBD_PID" "$NMBD_PID"
}
trap "stop_samba" SIGTERM SIGHUP

wait "$SMBD_PID" "$NMBD_PID"
