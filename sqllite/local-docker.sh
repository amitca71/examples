#!/bin/bash
source ../utils/ccloud_library.sh
source ../utils/helper.sh
WARMUP_TIME=80
source ../utils/config.env
source ~/.bashrc
docker-compose -f docker-compose.yml up -d --build
printf "\n====== Giving services $WARMUP_TIME seconds to startup\n"
sleep $WARMUP_TIME 
MAX_WAIT=240
echo "Waiting up to $MAX_WAIT seconds for connect to start"
retry $MAX_WAIT check_connect_up connect || exit 1
printf "\n\n"




