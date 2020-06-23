FROM ubuntu:latest

LABEL maintainer="Erik J. Olson <hello@erikjolson.com>"

ARG PORT
ARG MAGIC
ARG SHARED_KEY

RUN    apt update \
    && apt install -y wget \
                      nfs-kernel-server \
                      samba

RUN    wget https://github.com/dswd/vpncloud.rs/releases/download/v1.4.0/vpncloud_1.4.0_amd64.deb \
    && dpkg -i ./vpncloud_1.4.0_amd64.deb \
    && rm ./vpncloud_1.4.0_amd64.deb

COPY ./peers.txt peers.yaml
COPY ./subnets.txt subnets.yaml
COPY ./subspace.net /etc/vpncloud/

RUN    sed -i "s/%port%/$PORT/g" /etc/vpncloud/subspace.net \
    && sed -i "s/%magic%/$MAGIC/g" /etc/vpncloud/subspace.net \
    && sed -i "s/%sharedkey%/$SHARED_KEY/g" /etc/vpncloud/subspace.net \
    && sed -i "s/^/  - /g" peers.yaml \
    && sed -i "s/^/  - /g" subnets.yaml \
    && sed -i -e '/%peers%/{r peers.yaml' -e 'd}' /etc/vpncloud/subspace.net \
    && sed -i -e '/%subnets%/{r subnets.yaml' -e 'd}' /etc/vpncloud/subspace.net

EXPOSE 139 445 111 2049
