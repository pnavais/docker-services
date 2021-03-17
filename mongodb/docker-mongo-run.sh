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

ENABLE_AUTH=0

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
		--enable-auth)
			shift
			ENABLE_AUTH=1
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

if [ $ENABLE_AUTH == 1 ]; then
	pad "Enabling basic MongoDB authorization" 
	target_dir=$(mktemp -d -t docker_build-XXXXXXXXXX)
	if [ $? -eq 0 ]; then
		rsync -avz $CURRENT_DIR/ $target_dir &> /dev/null && sed -i -e "s/^#{AUTH_ENABLE}//g" $target_dir/Dockerfile &> /dev/null
	fi
	showResultOrExit
else
	target_dir=$CURRENT_DIR
fi

createImage $IMAGE_NAME $target_dir
showResultOrExit

if [ $ENABLE_AUTH == 1 ]; then
	rm -fr $target_dir
fi

EXTRA_ARGS="-p $(toFlatString "${PORTS_MAPPING[@]}")"
EXTRA_ARGS=$EXTRA_ARGS" -v $(toFlatString "${VOLS_MAPPING}")"

runContainer $CONTAINER_NAME $IMAGE_NAME $DISPLAY_NAME $RESTART_POLICY "$EXTRA_ARGS"
showResultOrExit
