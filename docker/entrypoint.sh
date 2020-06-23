#!/bin/sh

pcscd

ARG="${1-biss}"
case "$ARG" in
    proxy)
        cd /usr/share/btrust_biss/p11_libs/

        echo "Available Libraries: " *.so
        P11LIB="${2-libIDPrimePKCS11.so}"
        echo "Using: $P11LIB"

        if [ "$P11LIB" = "libcmP11.so" ]; then
            PROXY_CMD="pkcs11-daemon-x86"
        else
            PROXY_CMD="pkcs11-daemon-amd64"
        fi
        export PKCS11_DAEMON_SOCKET="tcp://0.0.0.0:53940"

        set -x
        $PROXY_CMD "./$P11LIB"
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
