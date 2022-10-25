#!/usr/bin/env bash


# Globals
#########

CURRENT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
DOCKER_COMMON_DIR="$CURRENT_DIR/../common";

source $DOCKER_COMMON_DIR/docker-functions.sh

VOLUME_NAME="arango_data"
IMAGE_NAME="arango-custom"
CONTAINER_NAME="arangodb_$OSTYPE"
DISPLAY_NAME="ArangoDB"
RESTART_POLICY="unless-stopped"

PORTS_MAPPING=("8529:8529")
VOLS_MAPPING=("$VOLUME_NAME:/var/lib/arangodb3")

# Entry point
# -----------

ROOT_PASSWORD="openSesame"
PARAMS=""

# Parse options

while (( "$#" )); do
	case "$1" in
		-v|--verbose)
			toggleVerbose
			;;
		--default)
			;;
		-p|--root-password)
			ROOT_PASSWORD="$2"
			if [ -z "$ROOT_PASSWORD" ]; then
				fail "Root password not specified";
				exit 1;
			fi
			shift 2
			;;
		--) # end argument parsing
			shift
			break
			;;
		*) # preserve positional arguments
			PARAMS="$PARAMS $1"
			shift
			;;
	esac
done

# set positional arguments in their proper place
eval set -- "$PARAMS"º

checkDocker

createVolume $VOLUME_NAME
showResultOrExit

pad "Setting ArangoDB root authentication" 
target_dir=$(mktemp -d -t docker_build-XXXXXXXXXX)
if [ $? -eq 0 ]; then
	rsync -avz $CURRENT_DIR/ $target_dir &> /dev/null && sed -i -e "s/#{ROOT_PASSWORD}/$ROOT_PASSWORD/g" $target_dir/Dockerfile &> /dev/null
fi
showResultOrExit

createImage $IMAGE_NAME $target_dir
showResultOrExit

pad "Performing image creation cleanup" 
rm -fr $target_dir
showResultOrExit

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"

runContainer $CONTAINER_NAME $IMAGE_NAME $DISPLAY_NAME $RESTART_POLICY "$EXTRA_ARGS"
showResultOrExit
