#!/bin/sh

IMAGE_NAME="${IMAGE_NAME:-btrust-biss}"
CONTAINER_NAME="${CONTAINER_NAME:-btrust-biss}"

if [ "$#" -eq 0 ]; then
	set -- biss
fi

ARG="$1"
case "$ARG" in
	proxy)
		DOCKER_ARGS="-p 127.0.0.1:53940:53940"
		;;
	biss)
		X11_SOCKET_PATH="/tmp/.X11-unix/"
		if [ ! -d "$X11_SOCKET_PATH" ]; then
			echo >&2 "ERR: Missing X11 socket directory at: $X11_SOCKET_PATH"
			exit 1
		fi
		XAUTHORITY_PATH="$HOME/.Xauthority"
		if [ ! -f "$XAUTHORITY_PATH" ]; then
			echo >&2 "ERR: Missing .Xauthority file at: $XAUTHORITY_PATH"
			exit 1
		fi

		HOSTNAME="$(hostname)"
		if [ -z "$HOSTNAME" ]; then
			echo >&2 "ERR: Unable to obtain hostname"
			exit 1
		fi

		DOCKER_ARGS="$DOCKER_ARGS -p 127.0.0.1:53952:53951"
		DOCKER_ARGS="$DOCKER_ARGS --hostname $HOSTNAME"
		DOCKER_ARGS="$DOCKER_ARGS -v $X11_SOCKET_PATH:/tmp/.X11-unix"
		DOCKER_ARGS="$DOCKER_ARGS -v $XAUTHORITY_PATH:/home/user/.Xauthority "
		DOCKER_ARGS="$DOCKER_ARGS -e XAUTHORITY=/home/user/.Xauthority "
		DOCKER_ARGS="$DOCKER_ARGS -e DISPLAY=$DISPLAY"
		;;
esac



set -x
exec docker run \
	--rm \
	-ti \
	--device /dev/bus/usb \
	--name "$CONTAINER_NAME" \
	$DOCKER_ARGS \
	"$IMAGE_NAME" \
	"$@"
