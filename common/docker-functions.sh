#!/usr/bin/env bash


# Globals
#########

SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd);

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

##############################################
# Converts array to flat string
# Params:
# - (1) array: Array of values
# Return:
# The flat string representation
##############################################
function toFlatString() {
	local arr=("$@")
	local ret=""
	local sep=""

	for i in "${arr[@]}"; do
		ret=${ret}${sep}$i
		sep=" "
	done

	echo "$ret";
}

##############################################
# Checks docker command availability
##############################################
function checkDocker() {
	if ! hash $DOCKER_CMD 2>/dev/null; then
		fail "Docker command not found [$DOCKER_CMD]";
		exit 1;
	fi
}

##############################################
# Checks whether a given volume exists and
# creates it if not found.
#  Params:
# - (1) volName : Name of the volume to create
##############################################
function createVolume() {
	local volName=$1;

	local volId=$($DOCKER_CMD volume ls -q -f name=$volName 2>/dev/null);

	pad "Creating volume \"$volName\""
	if [ -z "$volId" ]; then
		$DOCKER_CMD volume create $volName &>/dev/null
	else
		WARN_MSG="Volume found [$volName]"
	fi
}

##############################################
# Checks whether a given image exists and
# creates it if not found using a dockerfile
# pointed by the given path.
#  Params:
# - (1) imageName : Name of the image to create
#       (name[:version])
# - (2) dockerFilePath : path to the dockerfile
##############################################
function createImage() {
	local imageName=$1;
	local dockerFilePath=$2;

	local imageId=$($DOCKER_CMD images -q $imageName 2>/dev/null);

	pad "Building \"$imageName\" image"
	if [ -z "$imageId" ]; then
		$DOCKER_CMD build --tag $imageName $dockerFilePath &>/dev/null
	else
		WARN_MSG="Image found [$imageName : $imageId]"
	fi
}

##############################################
# Checks whether a given container is running
# or starts a new one using the supplied
# properties.
#  Params:
# - (1) containerName : Name of the container
# - (2) imageName     : Name of the image
# - (3) containerDisplayName : Name of the container
#       to display. (defaults to container name
#       if not set)
# - (4) restartPolicy : Container restart policy
#       (defaults to no if not set)
# - (5) extraArgs : Additional arguments
################################################
function runContainer() {
	local containerName=$1;
	local imageName=${2:-$containerName};
	local containerDisplayName=${3:-$containerName};
	local restartPolicy=${4:-"no"};
	local extraArgs=${5:-""};

	local containerId=$($DOCKER_CMD ps -q -f name=$containerName 2>/dev/null);

	pad "Starting $containerDisplayName container"
	if [ -z "$containerId" ]; then
		$DOCKER_CMD run -d --name=$containerName --restart=$restartPolicy $extraArgs $imageName &>/dev/null
	else
		WARN_MSG="Container already running [$containerName : $containerId]"
	fi
}

