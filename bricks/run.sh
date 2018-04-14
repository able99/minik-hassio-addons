#!/bin/bash
echo 'starting'

PATHNAME_OPTIONS=/data/options.json
PATHNAME_BRICKS=/config/bricks/
DESPATH=/config/

GITREPO=$(jq --raw-output '.gitrepo' $PATHNAME_OPTIONS)
PULL=$(jq --raw-output '.pull' $PATHNAME_OPTIONS)
OPTIONS=$(jq --raw-output '.options[]' $PATHNAME_OPTIONS)
BRICKS=$(jq --raw-output .bricks[] $PATHNAME_OPTIONS)


function env() {
  echo "-----prepare env-------"

  mkdir -p ${DESPATH}packages

  OPTIONS="gw="`route -n | head -3 | tail -1 | tr -s ' '| cut  -d ' ' -f 2`"\n"${OPTIONS}
  TMP=$(curl --connect-timeout 5 -s http://ip-api.com/json | jq -r 'if .status=="success" then "time_zone="+.timezone+"\nlatitude="+(.lat|tostring)+"\nlongitude="+(.lon|tostring) else error=.status end')
  OPTIONS=${TMP}"\n"${OPTIONS}

  echo -e $OPTIONS
}

function list() {
  echo "LIST $1"
  for i in $1/*
  do 
    DES=${i/${PATHNAME_BRICKS}${BRICK}/$DESPATH}
    if [ -d $i ]; then
      echo "DIR ${DES}"
      list $i
    elif [[ "$i" =~ .*.yaml$ ]]; then
      echo "DEAL ${i}=>${DES}"
      printf "${OPTIONS}\ncat << EOF\n$(cat ${i})\nEOF" | bash > ${DES}
    else
      echo "COPY ${i}=>${DES}"
      cp -r "${i}" "${DES}"
    fi
  done
}

function repo() {
  echo '--------git repo------'
  if [ -n "$GITREPO" -a "$PULL" == "true" ]; then
    rm -rf "$PATHNAME_BRICKS"
    git clone "$GITREPO" "$PATHNAME_BRICKS"
  else
    echo "not use git"
  fi
}

function bricks() {
  echo "------bricks---------"
  for BRICK in $BRICKS
  do   
    echo "------brick ${BRICK}---------"
    if [ ! -d ${PATHNAME_BRICKS}${BRICK} ]; then
      echo "!no this brick named ${BRICK}"
      continue
    fi

    list ${PATHNAME_BRICKS}${BRICK}
  done
}

env
repo
bricks
echo 'end'