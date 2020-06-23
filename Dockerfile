FROM ubuntu:latest

LABEL maintainer="Erik J. Olson <hello@erikjolson.com>"

ARG HOSTNAME
ARG PORT
ARG MAGIC
ARG SHARED_KEY

RUN echo $HOSTNAME > /etc/hostname

RUN    apt update \
    && apt install -y net-tools \
                      wget \
                      nfs-common \
                      samba

RUN    echo "deb https://repo.ddswd.de/deb stable main" | tee /etc/apt/sources.list.d/vpncloud.list \
    && wget https://repo.ddswd.de/deb/public.key -qO - | apt-key add \
    && apt update \
    && apt install vpncloud

COPY ./config/*.config ./
COPY ./services/vpncloud.net /etc/vpncloud/subspace.net
COPY ./services/samba.conf /etc/samba/smb.conf

RUN    sed -i "s/%port%/$PORT/g" /etc/vpncloud/subspace.net \
    && sed -i "s/%magic%/$MAGIC/g" /etc/vpncloud/subspace.net \
    && sed -i "s/%sharedkey%/$SHARED_KEY/g" /etc/vpncloud/subspace.net \
    && sed -i "s/%ipoctet%/$IP_OCTET/g" /etc/vpncloud/subspace.net \
    && sed -i "s/^/  - /g" peers.config \
    && sed -i "s/^/  - /g" subnets.config \
    && sed -i -e '/%peers%/{r peers.config' -e 'd}' /etc/vpncloud/subspace.net \
    && sed -i -e '/%subnets%/{r subnets.config' -e 'd}' /etc/vpncloud/subspace.net \
    && sed -r "s/^(.*),(.*),(r[ow])$/\/data\/Shared\/\1/g" shared.config | xargs -n1 mkdir -p \
    && sed -i -r "s/^(.*),(.*),(r[ow])$/\2 \/data\/Shared\/\1 nfs defaults,\3,nofail,_netdev 0 0/g" shared.config \
    && cat shared.config >> /etc/fstab

EXPOSE 8355 139 445

ENTRYPOINT ["/usr/bin/vpncloud", "--config", "/etc/vpncloud/subspace.net"]
