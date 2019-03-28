FROM ubuntu:bionic
# Note: alpine Linux's lifetime is rather short. Hence, I used bionic.

LABEL name="soga-denken"

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS=yes

ARG version

ARG PYTHON
ENV PYTHON=${PYTHON}

# in corpolate environment, there should be proxy.
# I believe you fed up with the proxy, so I prepared the setting for you.
RUN touch /etc/apt/apt.conf.d/01proxy                                                                                                           &&\
    if [ ! -z "${http_proxy}" ];  then echo 'Acquire::http:proxy "' "\b${http_proxy}" '\b";'   >> /etc/apt/apt.conf.d/01proxy; fi               &&\
    if [ ! -z "${https_proxy}" ]; then echo 'Acquire::https:proxy "' "\b${https_proxy}" '\b";' >> /etc/apt/apt.conf.d/01proxy; fi               &&\
    if [ ! -z "${ftp_proxy}" ];   then echo 'Acquire::ftp:proxy "' "\b${ftp_proxy}" '\b";'     >> /etc/apt/apt.conf.d/01proxy; fi               &&\                                                                      
# uncomment the next line if you are in Japan
    sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.jaist.ac.jp/pub/Linux/ubuntu/%g" /etc/apt/sources.list                        &&\ 
    export http_proxy="${http_proxy}"                                                                                                           &&\
    export https_proxy="${https_proxy}"                                                                                                          &&\
    export ftp_proxy="${ftp_proxy}"                                                                                                          &&\
    export no_proxy="${no_proxy}"                                        

# Then update
# these package names are obtained from SAMBA's documentation
# several package names are modified for ubuntu 18.04
#  vim net-tools added fror debug purpose
# ca-certificates for wget
RUN apt-get -qq update -y && apt-get -qq upgrade -y        &&\
    apt-get -qq install --no-install-recommends wget         \
    acl attr autoconf bind9utils bison build-essential       \
    debhelper dnsutils docbook-xml docbook-xsl flex gdb      \
    libjansson-dev krb5-user libacl1-dev libaio-dev          \  
    libarchive-dev libattr1-dev libblkid-dev libbsd-dev      \
    libcap-dev libcups2-dev libgnutls28-dev libgpgme-dev     \
    libjson-perl libldap2-dev libncurses5-dev libpam0g-dev   \
    libparse-yapp-perl libpopt-dev libreadline-dev           \
    nettle-dev perl perl-modules pkg-config python-all-dev   \
    python-crypto python-dbg python-dev python-dnspython     \
    python3-dnspython python-gpg python3-gpg python-markdown \
    python3-markdown python3-dev xsltproc zlib1g-dev         \
    liblmdb-dev lmdb-utils supervisor openvpn inetutils-ping \
    ca-certificates vim net-tools libtasn1-bin

# todo: replace the version with the environmental variable
RUN mkdir /build
RUN cd /build && wget https://download.samba.org/pub/samba/stable/samba-${version}.tar.gz
RUN cd /build && tar xfz samba-${version}.tar.gz
WORKDIR /build/samba-${version}

# patch the security update
## No known security patch
# todo write a code to add security patch for each version

# install samba with the Filesystem Hierarchy Standard
# fixme. this should be controlled by docker-compose since python2 is no longer supported from 4.10.1
#ENV PYTHON=python2

RUN ls &&  ./configure --enable-gnutls --enable-fhs --prefix=/usr --sysconfdir=/etc --localstatedir=/var -j `nproc`
RUN make -j `nproc`
RUN make install

# Set up script and run
ADD startup.sh /startup.sh
RUN chmod 755 /startup.sh
CMD /startup.sh