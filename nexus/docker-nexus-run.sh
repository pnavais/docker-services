#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh 

VOLUME_NAME="nexus_data"
IMAGE_NAME="nexus-custom"
CONTAINER_NAME="nexus_$OSTYPE"
DISPLAY_NAME="Nexus 3"
RESTART_POLICY="always"

PORTS_MAPPING=( "8081:8081" )
VOLS_MAPPING=( "$VOLUME_NAME:/nexus-data")

# Entry point
# -----------

checkDocker

createVolume $VOLUME_NAME 
showResultOrExit

createImage $IMAGE_NAME $CURRENT_DIR
showResultOrExit

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"

runContainer "$CONTAINER_NAME" "$IMAGE_NAME" "$DISPLAY_NAME" "$RESTART_POLICY" "$EXTRA_ARGS"
showResultOrExit 
