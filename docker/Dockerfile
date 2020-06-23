FROM ubuntu:16.04 as build-pkcs11-proxy

RUN apt-get update \
    && apt-get -y install git build-essential cmake libseccomp-dev libssl-dev \
		&& rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src
RUN git clone https://github.com/SUNET/pkcs11-proxy.git \
    && cd pkcs11-proxy \
		&& mkdir build \
		&& cd build \
		&& cmake .. \
		&& make


FROM ubuntu:16.04
LABEL maintainer="Marin Ivanov <dev@metala.org>"

WORKDIR /usr/src/build
RUN apt-get update \
    && apt-get -y install \
        pcsc-tools \
        libacsccid1 \
        libccid \
        libpcsclite1 \
        libssl1.0.0 \
        zlib1g \
        opensc \
        opensc-pkcs11 \
				libboost-system1.58.0 \
				libboost-filesystem1.58.0 \
				libboost-serialization1.58.0 \
				libboost-thread1.58.0 \
				libxtst6 \
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

COPY --from=build-pkcs11-proxy /usr/local/src/pkcs11-proxy/build/pkcs11-daemon /usr/local/bin/

COPY ./entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]

