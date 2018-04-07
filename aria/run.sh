#!/bin/bash
echo 'starting'

PATHNAME_CONFIG=/share/aria2/aria2.conf
PATHNAME_SESSION=/share/aria2/aria2.session

mkdir -p /share/aria2
touch $PATHNAME_SESSION
if [ -f $PATHNAME_CONFIG ]; then
    echo 'check config...'
else
    echo 'config...'
    cp /aria2.conf $PATHNAME_CONFIG
fi

echo 'trackers'
TRACKERS=$(curl -s https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt | xargs | sed 's/ /,/g')
sed -i'' "s#\(bt-tracker=\).*#\1${TRACKERS}#" $PATHNAME_CONFIG
echo '--------'
cat $PATHNAME_CONFIG 
echo '--------'

aria2c --conf-path=$PATHNAME_CONFIG