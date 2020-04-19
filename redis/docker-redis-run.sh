#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh 

VOLUME_NAME="redis_data"
IMAGE_NAME="redis-custom"
CONTAINER_NAME="redis_$OSTYPE"
DISPLAY_NAME="Redis"
RESTART_POLICY="always"

PORTS_MAPPING=( "6379:6379" )
VOLS_MAPPING=( "$VOLUME_NAME:/data")

# Entry point
# -----------

checkDocker

createVolume $VOLUME_NAME 
showResultOrExit

createImage $IMAGE_NAME $CURRENT_DIR
showResultOrExit

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"

runContainer $CONTAINER_NAME $IMAGE_NAME $DISPLAY_NAME $RESTART_POLICY "$EXTRA_ARGS"
showResultOrExit 
