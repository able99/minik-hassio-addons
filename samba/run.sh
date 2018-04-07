#!/bin/bash
echo starting

set -e

PATHNAME_SMB=/etc/smb.conf
PATHNAME_OPTIONS=/data/options.json

function showWelcome() {
    echo 'starting by config:'
    cat $PATHNAME_OPTIONS
    echo '-------------------'
}
function configGlobal() {
    echo '-config global-'
    NAME=$(jq --raw-output '.name' $PATHNAME_OPTIONS)
    WORKGROUP=$(jq --raw-output '.workgroup' $PATHNAME_OPTIONS)
    INTERFACE=$(jq --raw-output '.interface // empty' $PATHNAME_OPTIONS)
    LOGLEVEL=$(jq --raw-output '.loglevel // empty' $PATHNAME_OPTIONS)
    GUEST=$(jq --raw-output '.guest' $PATHNAME_OPTIONS)
    GUESTCONFIG1=
    GUESTCONFIG2=
    if [ "$GUEST" == "true" ]; then
        GUESTCONFIG1="guest account = root"
        GUESTCONFIG2="map to guest = Bad Password"
    fi

    echo "
[global]
   netbios name = $NAME
   workgroup = $WORKGROUP
   server string = Minik Samba 
   security: user

   load printers = no
   disable spoolss = yes

   log level = $LOGLEVEL
   
   bind interfaces only = yes
   interfaces = $INTERFACE

   $GUESTCONFIG1
   $GUESTCONFIG2

" > $PATHNAME_SMB
}

function configUser() {
    echo '-config user-'
    for i in $(jq --raw-output 'range(.users|length)' $PATHNAME_OPTIONS); 
    do 
        USERNAME=$(jq --raw-output ".users[$i].username" $PATHNAME_OPTIONS)
        PASSWORD=$(jq --raw-output ".users[$i].password" $PATHNAME_OPTIONS)
        echo "set: $USERNAME:$PASSWORD"
        addgroup -g 1000 "$USERNAME"
        adduser -D -H -G "$USERNAME" -s /bin/false -u 1000 "$USERNAME"
        echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/smb.conf "$USERNAME"
    done  
}

function configItem() {
    echo "config item: use=$1 name=$2 path=$3 browseable=$4 writeable=$5"
    BROWSEABLE=no
    WRITEABLE=no
    if [ "$4" == "true" ]; then
        BROWSEABLE=yes
    fi
    if [ "$5" == "true" ]; then
        WRITEABLE=yes
    fi

    if [ "$1" == "guest" ]; then
        echo "
[$2]
   browseable = $BROWSEABLE
   writeable = $WRITEABLE
   path = $3

   guest ok = yes
   guest only = yes
   public = yes

" >> $PATHNAME_SMB
    elif [ -n "$2" ]; then
        echo "
[$2]
   browseable = $BROWSEABLE
   writeable = $WRITEABLE
   path = $3

   valid users = $1
   force user = root
   force group = root

" >> $PATHNAME_SMB
   fi
}

function configItems() {
    echo '-config items-'
    for i in $(jq --raw-output 'range(.items|length)' $PATHNAME_OPTIONS); 
    do 
        ARGS=$(jq --raw-output ".items[$i]|.use, .name, .pathname, .browseable, .writeable" $PATHNAME_OPTIONS | xargs)
        configItem $ARGS
    done  
}

function showStart() {
    echo 'ready:'
    cat $PATHNAME_SMB
    echo '-----------'
}



showWelcome
configGlobal
configUser
configItems
showStart

nmbd -F -S -s $PATHNAME_SMB &
NMBD_PID=$!
smbd -F -S -s $PATHNAME_SMB &
SMBD_PID=$!

function stop_samba() {
    kill -15 "$NMBD_PID"
    kill -15 "$SMBD_PID"
    wait "$SMBD_PID" "$NMBD_PID"
}
trap "stop_samba" SIGTERM SIGHUP

wait "$SMBD_PID" "$NMBD_PID"
