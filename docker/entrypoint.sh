#!/bin/sh

pcscd

ARG="${1-biss}"
case "$ARG" in
	proxy)
		cd /usr/share/btrust_biss/p11_libs/

		echo "Available Libraries: " *.so
		P11LIB="${2-libIDPrimePKCS11.so}"
		echo "Using: $P11LIB"

		set -x
		PKCS11_DAEMON_SOCKET="tcp://0.0.0.0:53940" pkcs11-daemon "./$P11LIB"
		;;
	biss)
		echo "Running 'btrust_biss' application..."
		sudo -u user -H -- btrust_biss
		BISS_PID="$(pgrep -f btrust_biss)"
		echo "Starting TCP proxy (0.0.0.0:53951 -> 127.0.0.1:53952)..."
		socat TCP4-LISTEN:53951,fork,reuseaddr TCP-CONNECT:127.0.0.1:53952 &

		echo "Waiting for log file to appear..."
		while [ ! -f ./BISS.log ]; do sleep 1; done

		echo "Waiting for the application to terminate..."
		tail --pid="$BISS_PID" -f ./BISS.log
		;;
	*)
		"$@"
		;;
esac
