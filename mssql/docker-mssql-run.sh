#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh

VOLUME_NAME="mssql_data"
IMAGE_NAME="mssql-custom"
CONTAINER_NAME="mssql_$OSTYPE"
DISPLAY_NAME="SQL Server"
RESTART_POLICY="always"

PORTS_MAPPING=("1433:1433")
VOLS_MAPPING=("$VOLUME_NAME:/var/opt/mssql")

# Entry point
# -----------

toggleVerbose

checkDocker

createVolume $VOLUME_NAME
showResultOrExit

createImage $IMAGE_NAME $CURRENT_DIR
showResultOrExit

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"
EXTRA_ARGS="$EXTRA_ARGS --hostname $CONTAINER_NAME"

runContainer $CONTAINER_NAME $IMAGE_NAME "$DISPLAY_NAME" $RESTART_POLICY "$EXTRA_ARGS"
showResultOrExit
