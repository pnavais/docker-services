#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh 

IMAGE_NAME="rabbit-custom"
CONTAINER_NAME="rabbit_$OSTYPE"
DISPLAY_NAME="RabbitMQ"
RESTART_POLICY="always"

PORTS_MAPPING=( "5672:5672" "15672:15672" )

# Entry point
# -----------

checkDocker

createImage $IMAGE_NAME $CURRENT_DIR
showResultOrExit

PORTS="$(toFlatString "${PORTS_MAPPING[@]}")"
PORTS=${PORTS// / -p }
EXTRA_ARGS="-p $PORTS"
EXTRA_ARGS="$EXTRA_ARGS --hostname $IMAGE_NAME"

runContainer "$CONTAINER_NAME" "$IMAGE_NAME" "$DISPLAY_NAME" "$RESTART_POLICY" "$EXTRA_ARGS"
showResultOrExit 
