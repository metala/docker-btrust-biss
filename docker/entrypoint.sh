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
		set -x
		sudo -u user -H -- btrust_biss
		socat TCP4-LISTEN:53951,fork,reuseaddr TCP-CONNECT:127.0.0.1:53952
		;;
	*)
		"$@"
		;;
esac
