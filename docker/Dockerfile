FROM ubuntu:16.04 as build-pkcs11-proxy

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y install git build-essential cmake libseccomp-dev libssl-dev gcc-multilib libseccomp-dev:i386 libssl-dev:i386 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src
COPY ./pkcs11-proxy-march32.patch ./
RUN git clone https://github.com/metala/pkcs11-proxy.git \
    && cd pkcs11-proxy \
    && patch -p1 < ../pkcs11-proxy-march32.patch \
    && mkdir build64 build32 \
    && cd build64 && cmake .. && make \
    && cd ../build32 && cmake -DCMAKE_BUILD_MARCH=32 .. && make


FROM ubuntu:16.04
LABEL maintainer="Marin Ivanov <dev@metala.org>"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -y install \
        pcscd \
        pcsc-tools \
        libacsccid1 \
        libccid \
        libpcsclite1 \
        libssl1.0.0 \
        libseccomp2 \
        zlib1g \
        libboost-system1.58.0 \
        libboost-filesystem1.58.0 \
        libboost-serialization1.58.0 \
        libboost-thread1.58.0 \
        libxtst6 \
        libpcsclite1:i386 \
        libssl1.0.0:i386 \
        libseccomp2:i386 \
        zlib1g:i386 \
        libstdc++6:i386 \
        wget \
        sudo \
        socat \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 user \
    && useradd -d /home/user -s /bin/bash -m user -u 1000 -g 1000

# Install BISS
COPY ./btrustbiss.deb.sha256sum /tmp
RUN cd /tmp \
        && wget --progress=dot 'http://www.b-trust.bg/attachments/BtrustPrivateFile/24/docs/B-TrustBISS.tar' \
        && tar xf B-TrustBISS.tar \
    && sha256sum --check ./btrustbiss.deb.sha256sum \
    && dpkg -i ./btrustbiss.deb \
        && rm *.tar *.deb *.sha256sum

# Ad-hoc fixes for BISS applicaiton
RUN ln -s /lib/x86_64-linux-gnu/libpcsclite.so.1.0.0 /usr/lib/x86_64-linux-gnu/libpcsclite.so.1.0.0 \
 && ln -s /usr/share/btrust_biss/p11_libs/libIDPrimePKCS11.so /usr/lib/libIDPrimePKCS11.so.10

COPY --from=build-pkcs11-proxy /usr/local/src/pkcs11-proxy/build32/pkcs11-daemon /usr/local/bin/pkcs11-daemon-x86
COPY --from=build-pkcs11-proxy /usr/local/src/pkcs11-proxy/build64/pkcs11-daemon /usr/local/bin/pkcs11-daemon-amd64
COPY ./entrypoint.sh /usr/local/bin/

WORKDIR /usr/share/btrust_biss/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]

