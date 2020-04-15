#!/usr/bin/env bash


# Globals
#########

SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
REDIS_VOLUME_NAME="redis_data"
REDIS_IMAGE_NAME="redis-custom"
REDIS_CONTAINER_NAME="redis_$OSTYPE"

RES_OK="\xE2\x9C\x94"   #"\u2714";
RES_FAIL="\xE2\x9C\x96" #"\u2716";
RES_WARN="\xE2\x9A\xA0" #"\u2716";

# Functions
###########

#######################################
# Shows a debug message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function debug() {
    printf "\e[0;33m$1\e[0m";
}

#######################################
# Shows a success message (Green color)
# Params:
# - (1) msg : String to show
#######################################
function success() {
    printf "\e[0;32m$1\e[0m";
}

#######################################
# Shows a fail message (Red color)
# Params:
# - (1) msg : String to show
#######################################
function fail() {
    printf "\e[0;31m$1\e[0m";
}

#######################################
# Shows a warning message (Yellow color)
# Params:
# - (1) msg : String to show
#######################################
function warn() {
    debug "WARN: $1\n"
}

###################################
# Shows the result of an operation
###################################
function showResult() {
    local err=${1-$?};
    if [[ $err -eq 0 ]]; then
        success "$RES_OK\n";
    else
        fail "$RES_FAIL\n";
    fi
}

###################################
# Shows the result of an operation
# and exit if return code not 0
###################################
function showResultOrExit() {
    local err=$?;
    showResult $err;
    if [[ $err -ne 0 ]]; then
        exit -1;
    fi
}

# Entry point
# -----------

VOLUME_NAME=$(docker volume ls -q -f name=$REDIS_VOLUME_NAME 2>/dev/null);

if [ -z "$VOLUME_NAME" ]; then
	printf "Creating volume \"$REDIS_VOLUME_NAME\"..."
	docker volume create $REDIS_VOLUME_NAME &>/dev/null
	showResultOrExit
else 
	warn "Docker volume already existing [$VOLUME_NAME]"
fi

IMAGE_HASH=$(docker images -q $REDIS_IMAGE_NAME 2>/dev/null);

if [ -z "$IMAGE_HASH" ]; then
	printf "Building \"$REDIS_IMAGE_NAME\" docker image..."
	docker build --tag $REDIS_IMAGE_NAME $SCRIPT_DIR &>/dev/null
	showResultOrExit
else 
	warn "Docker image already existing [$REDIS_IMAGE_NAME : $IMAGE_HASH]"
fi

CONTAINER_HASH=$(docker ps -q -f name=$REDIS_CONTAINER_NAME 2>/dev/null);

if [ -z "$CONTAINER_HASH" ]; then
	printf "Starting Redis container..."
        docker run -d --name=$REDIS_CONTAINER_NAME -v $REDIS_VOLUME_NAME:/data $REDIS_IMAGE_NAME &>/dev/null
	showResultOrExit
else 
	warn "Docker container already running [$REDIS_CONTAINER_NAME : $CONTAINER_HASH]"
fi
