#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh

VOLUME_NAME="mongo_data"
IMAGE_NAME="mongo-custom"
CONTAINER_NAME="mongodb_$OSTYPE"
DISPLAY_NAME="MongoDB"
RESTART_POLICY="always"

PORTS_MAPPING=("27017:27017")
VOLS_MAPPING=("$VOLUME_NAME:/data/db")

# Entry point
# -----------

# Parse options
for arg in "$@"
do
	case $arg in
		-v|--verbose)
			toggleVerbose
			;;
		--default)
			shift # past argument with no value
			;;
		*)
			# unknown option
			printf "Invalid option: $arg\n" >&2
			exit -1;
			;;
	esac
done

checkDocker

createVolume $VOLUME_NAME
showResultOrExit

createImage $IMAGE_NAME $CURRENT_DIR
showResultOrExit

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"

runContainer $CONTAINER_NAME $IMAGE_NAME $DISPLAY_NAME $RESTART_POLICY "$EXTRA_ARGS"
showResultOrExit
