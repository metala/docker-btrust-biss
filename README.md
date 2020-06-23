Docker container for the Borica B-Trust BISS and security modules

# Motivation

Borica B-Trust security tokens PKCS11 library is built for Ubuntu 16.04 (xenial). In order to use
their tokens and BISS application, we need to install specific
version of boost and ensure compatilibity.

# Building

```bash
# To build the container, you need to run ./build.sh
$ ./build.sh
```

# Usage

## BISS
Borica B-Trust BISS (Browser Independent Signing Service) 

Note: it binds on `127.0.0.1:53952` and since it is containerized, there is an additional 
intermediate TCP proxy (socat) that will forward the connections the application.

```bash
# Use this to start BISS on port 53952
$ ./run.sh biss
# or simply
$ ./run.sh
```

## PKCS11 Proxy

In order to use the PKCS11 proxy, you first need to build and install [PKCS11 Proxy library](https://github.com/SUNET/pkcs11-proxy).

```bash
# Use this line to start PKCS11 TCP proxy on port 53940
$ ./run.sh proxy
# that defaults to
$ ./run.sh proxy libIDPrimePKCS11.so

# or this one, depending on which security token you are using.
$ ./run.sh proxy libcvP11.so
```

Then you can access the token using `pkcs11-tool` and the proxy module.

```bash
/usr/src/pkcs11-proxy/build$ export PKCS11_PROXY_SOCKET=tcp://127.0.0.1:53940
/usr/src/pkcs11-proxy/build$ pkcs11-tool --module ./libpkcs11-proxy.so -O
Using slot 0 with a present token (0x0)
Certificate Object; type = X.509 cert
<...command output truncated here...>
```