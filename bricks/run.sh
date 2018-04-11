#!/bin/bash
echo 'starting'

PATHNAME_OPTIONS=/data/options.json
PATHNAME_BRICKS=/config/bricks/

GITREPO=$(jq --raw-output '.gitrepo' $PATHNAME_OPTIONS)
PULL=$(jq --raw-output '.pull' $PATHNAME_OPTIONS)
OPTIONS=$(jq -r '.options|to_entries|map(.key+"="+.value)|.[]' $PATHNAME_OPTIONS)
DESPATH=/config
#printf "$(jq -r '.options.options|to_entries|map(.key+"="+.value)|.[]' config.json)\ncat << EOF\n$(cat 1.yaml)\nEOF" | bash > 2.yaml
echo '----------'
echo -e $OPTIONS
echo '----------'

for BRICK in $(jq --raw-output .bricks[] $PATHNAME_OPTIONS)
do   
  echo "------brick ${BRICK}---------"
  if [ ! -d ${PATHNAME_BRICKS}${BRICK} ]; then
    echo "!no this brick named ${BRICK}"
    continue
  fi

  for FILE in ${PATHNAME_BRICKS}${BRICK}/*
  do
    if [ "$FILE" == "${PATHNAME_BRICKS}${BRICK}/packages" ]; then
      for PACKAGE in ${FILE}/*
      do
        PACKAGENAME=$(basename $PACKAGE)
        echo "DEAL ${PACKAGE}=>${DESPATH}/packages/${PACKAGENAME}"
        printf "${OPTIONS}\ncat << EOF\n$(cat ${PACKAGE})\nEOF" | bash > ${DESPATH}/packages/${PACKAGENAME}
      done
    else
      echo "COPY ${FILE}=>${DESPATH}"
      cp -r "${FILE}" "${DESPATH}"
    fi
  done
done
