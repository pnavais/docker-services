#!/usr/bin/env bash


# Globals
#########

SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);
REDIS_VOLUME_NAME="redis_data"
REDIS_IMAGE_NAME="redis-custom"
REDIS_CONTAINER_NAME="redis_$OSTYPE"
HOST_PORT=6379
REDIS_CONTAINER_PORT=6379
DOCKER_CMD="docker"

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
	debug "$1"
}

###################################
# Shows the result of an operation
###################################
function showResult() {
	local err=${1-$?};
	if [[ $err -eq 0 ]]; then
		success "${RES_OK}";
	else
		fail "${RES_FAIL}";
	fi

	if [ -n "$WARN_MSG" ]; then
		warn " ($WARN_MSG)";
	fi

	printf "\n";
	WARN_MSG="";
}

###################################
# Shows the result of an operation
# and exit if return code not 0
###################################
function showResultOrExit() {
	local err=$?;
	showResult $err;
	if [[ $err -ne 0 ]]; then
		exit 2;
	fi
}

##############################################
# Pads a message with the given character
# up to the percentage of maximum terminal
# available width.
#
# params:
#   - (1) msg          : the message to pad
#   - (2) width_ratio  : the width percentage
#   - (3) padding_char : the character used in
#                        the padding.
##############################################
function padding() {
	local msg=$1;
	local width_ratio=$2;
	local padding_char=$3;
	local stripped_msg=$(stripAnsi "$msg");
	local cur_size=${#stripped_msg};
	local max_width=$(tput cols);
	local max_padding=$((max_width*width_ratio/100));

	while [ $cur_size -lt $max_padding ]; do
		let cur_size+=1;
		msg=${msg}${padding_char};
	done

	printf "$msg";
}

##############################################
# Pads a message with the given characters
# up to the percentage of maximum terminal
# available width.
#
# params:
#   - (1) msg          : the message to pad
##############################################
function pad() {
	padding "$1" 40 '.';
}

##############################################
# Removes ANSI sequences from a given String
# Params:
# - (1) msg : String to remove ANSI sequences
##############################################
function stripAnsi() {
	echo -e $1 | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g";
}

# Entry point
# -----------

if ! hash $DOCKER_CMD 2>/dev/null; then
	fail "Docker command not found [$DOCKER_CMD]";
	exit 1;
fi

VOLUME_NAME=$($DOCKER_CMD volume ls -q -f name=$REDIS_VOLUME_NAME 2>/dev/null);

pad "Creating volume \"$REDIS_VOLUME_NAME\""
if [ -z "$VOLUME_NAME" ]; then
	$DOCKER_CMD volume create $REDIS_VOLUME_NAME &>/dev/null
else
	WARN_MSG="Volume found [$VOLUME_NAME]"
fi
showResultOrExit

IMAGE_HASH=$($DOCKER_CMD images -q $REDIS_IMAGE_NAME 2>/dev/null);

pad "Building \"$REDIS_IMAGE_NAME\" image"
if [ -z "$IMAGE_HASH" ]; then
	$DOCKER_CMD build --tag $REDIS_IMAGE_NAME $SCRIPT_DIR &>/dev/null
else
	WARN_MSG="Image found [$REDIS_IMAGE_NAME : $IMAGE_HASH]"
fi
showResultOrExit

CONTAINER_HASH=$($DOCKER_CMD ps -q -f name=$REDIS_CONTAINER_NAME 2>/dev/null);

pad "Starting Redis container"
if [ -z "$CONTAINER_HASH" ]; then
	$DOCKER_CMD run -d --name=$REDIS_CONTAINER_NAME --restart=always -p $HOST_PORT:$REDIS_CONTAINER_PORT -v $REDIS_VOLUME_NAME:/data $REDIS_IMAGE_NAME &>/dev/null
else
	WARN_MSG="Container already running [$REDIS_CONTAINER_NAME : $CONTAINER_HASH]"
fi
showResultOrExit 
