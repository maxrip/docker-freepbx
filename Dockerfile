FROM tiredofit/debian:bookworm-latest

LABEL maintainer="Maxim (maxrip at gmail dot com)"


### Set defaults
ENV ASTERISK_VERSION=20.6.0 \
    BCG729_VERSION=1.1.1 \
    G72X_CPUHOST=penryn \
    G72X_BRANCH=20 \
#    MONGODB_VERSION=6.0 \
    PHP_VERSION=7.4 \
    SPANDSP_VERSION=20180108 \
    RTP_START=18000 \
    RTP_FINISH=20000 \
    ASTERISK_BUILD_DEPS='\
                        autoconf \
                        cmake \
                        automake \
                        bison \
                        binutils-dev \
                        build-essential \
                        doxygen \
                        flex \
                        graphviz \
                        libasound2-dev \
                        libc-client2007e-dev \
                        libcfg-dev \
                        libcodec2-dev \
                        libcorosync-common-dev \
                        libcpg-dev \
                        libcurl4-openssl-dev \
                        libedit-dev \
                        libfftw3-dev \
                        libgmime-3.0-dev \
                        libgsm1-dev \
                        libical-dev \
                        libiksemel-dev \
                        libjansson-dev \
                        libldap2-dev \
                        liblua5.2-dev \
                        libmariadb-dev \
                        libmariadb-dev-compat \
                        libmp3lame-dev \
                        libncurses5-dev \
                        libneon27-dev \
                        libnewt-dev \
                        libogg-dev \
                        libopus-dev \
                        libosptk-dev \
                        libpopt-dev \
                        libradcli-dev \
                        libresample1-dev \
                        libsndfile1-dev \
                        libsnmp-dev \
                        libspeex-dev \
                        libspeexdsp-dev \
                        libsqlite3-dev \
                        libsrtp2-dev \
                        libssl-dev \
                        libtiff-dev \
                        libtool-bin \
                        libunbound-dev \
                        liburiparser-dev \
                        libvorbis-dev \
                        libvpb-dev \
                        libxml2-dev \
                        libxslt1-dev \
                        portaudio19-dev \
                        python3-dev \
                        subversion \
                        unixodbc-dev \
                        uuid-dev \
                        zlib1g-dev'
                        
### Pin libxml2 packages to Debian repositories
RUN echo "Package: libxml2*" > /etc/apt/preferences.d/libxml2 && \
    echo "Pin: release o=Debian,n=bookworm" >> /etc/apt/preferences.d/libxml2 && \
    echo "Pin-Priority: 501" >> /etc/apt/preferences.d/libxml2 && \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=TRUE && \
    \
### Install dependencies
    set -x && \
#change mirror
    sed -i 's|deb.debian.org|mirror.yandex.ru|g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    apt install -y gnupg curl lsb-release && \
    curl -sSLk https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
#    curl -sSLk https://www.mongodb.org/static/pgp/server-${MONGODB_VERSION}.asc | apt-key add - && \
#    echo "deb http://repo.mongodb.org/apt/debian/ $(lsb_release -sc)/mongodb-org/${MONGODB_VERSION} main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    echo "deb http://mirror.yandex.ru/debian/ $(lsb_release -sc)-backports main" > /etc/apt/sources.list.d/backports.list && \
    echo "deb-src http://mirror.yandex.ru/debian/ $(lsb_release -sc)-backports main" >> /etc/apt/sources.list.d/backports.list && \
    apt-get update && \

### Install runtime dependencies
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
                    $ASTERISK_BUILD_DEPS \
                    apache2 \
                    composer \
                    fail2ban \
                    ffmpeg \
                    flite \
                    freetds-dev \
                    git \
                    g++ \
                    iptables \
                    lame \
                    libavahi-client3 \
                    libc-client2007e \
                    libcfg7 \
                    libcpg4 \
                    libgmime-3.0 \
                    libical3 \
                    libiodbc2 \
                    libiksemel3 \
                    libicu72 \
                    libicu-dev \
                    libneon27 \
                    libosptk4 \
                    libresample1 \
                    libsnmp-base \
                    libspeexdsp1 \
                    libsrtp2-1 \
                    libunbound8 \
                    liburiparser1 \
                    libvpb1 \
                    locales \
                    locales-all \
                    make \
                    mariadb-client \
#                    mariadb-server \
#                    mongodb-org \
                    mpg123 \
                    nodejs \
                    npm \
                    odbc-mariadb \
                    php${PHP_VERSION} \
                    php${PHP_VERSION}-curl \
                    php${PHP_VERSION}-cli \
                    php${PHP_VERSION}-mysql \
                    php${PHP_VERSION}-gd \
                    php${PHP_VERSION}-mbstring \
                    php${PHP_VERSION}-intl \
                    php${PHP_VERSION}-bcmath \
                    php${PHP_VERSION}-ldap \
                    php${PHP_VERSION}-xml \
                    php${PHP_VERSION}-zip \
                    php${PHP_VERSION}-sqlite3 \
                    php-pear \
                    pkg-config \
                    sipsak \
                    sngrep \
                    socat \
                    sox \
                    sqlite3 \
                    tcpdump \
                    tcpflow \
                    unixodbc \
                    uuid \
                    wget \
                    whois \
                    xmlstarlet \
                    subversion \
                    bzip2 && \
    
### Add users
    addgroup --gid 2600 asterisk && \
    adduser --uid 2600 --gid 2600 --gecos "Asterisk User" --disabled-password asterisk && \
# && \
#    \
### Build SpanDSP
#    mkdir -p /usr/src/spandsp && \
#    curl -ssLk http://sources.buildroot.net/spandsp/spandsp-${SPANDSP_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/spandsp && \
#    cd /usr/src/spandsp && \
#    ./configure --help && \
#    ./configure --prefix=/usr && \
#    make && \
#    make install
# && \
#    \

### download Asterisk

    cd /usr/src && \
    mkdir -p asterisk && \
    curl -sSLk http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz | tar xvfz - --strip 1 -C /usr/src/asterisk && \
### Build Asterisk
    cd /usr/src/asterisk/ && \
    contrib/scripts/get_mp3_source.sh && \
    contrib/scripts/install_prereq install && \
    cd /usr/src/asterisk && \
    ./configure \
        --with-jansson-bundled \
        --with-pjproject-bundled \
        --without-bluetooth \
        --with-codec2 \
        --with-crypto \
        --with-gmime \
        --with-iconv \
        --with-iksemel \
        --with-inotify \
#        --with-ldap \
        --with-libxml2 \
        --with-libxslt \
        --with-lua \
        --with-ogg \
        --with-opus \
        --with-resample \
#        --with-spandsp \
        --with-speex \
        --with-sqlite3 \
        --with-srtp \
        --with-unixodbc \
        --with-uriparser \
        --with-vorbis \
        --with-vpb && \
    cd /usr/src/asterisk && \
    make menuselect.makeopts && \
    menuselect/menuselect --disable BUILD_NATIVE \
                          --enable-category MENUSELECT_ADDONS \
                          --enable-category MENUSELECT_APPS \
                          --enable-category MENUSELECT_CHANNELS \
                          --enable-category MENUSELECT_CODECS \
                          --enable-category MENUSELECT_FORMATS \
                          --enable-category MENUSELECT_FUNCS \
                          --enable-category MENUSELECT_RES \
                          --enable BETTER_BACKTRACES \
                          --disable MOH-OPSOUND-WAV \
                          --enable MOH-OPSOUND-GSM \
                          --disable app_voicemail_imap \
                          --disable app_voicemail_odbc \
                          --disable res_digium_phone \
                          --disable codec_g729a \
#                          --disable chan_phone \
                          --disable chan_iax2 \
                          --disable chan_mgcp \
#                          --disable chan_misdn \
#                          --disable chan_oss \
                          --disable chan_skinny \
                          --disable chan_unistim \
#                          --disable chan_vpb \
                          --disable chan_motif \
                          --enable format_mp3 \
\
    make -j`nproc --all` && \
    make install && \
    make install-headers && \
    make config && \
#### Add G729 codecs
    git clone https://github.com/BelledonneCommunications/bcg729 /usr/src/bcg729 && \
    cd /usr/src/bcg729 && \
#    git checkout tags/$BCG729_VERSION && \
#    ./autogen.sh && \
#    ./configure --prefix=/usr --libdir=/lib && \
    cmake . -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_PREFIX_PATH=/lib && \
    make && \
    make install && \
    \
    cd /usr/src && \
    git clone https://github.com/maxrip/asterisk-g72x.git -b $G72X_BRANCH --depth 1 && \
    cd /usr/src/asterisk-g72x && \
    git checkout $G72X_BRANCH && \
    ./autogen.sh && \
    ./configure --prefix=/usr --with-bcg729 --enable-$G72X_CPUHOST && \
    make && \
    make install && \
    \
### Cleanup
    mkdir -p /var/run/fail2ban && \
    cd / && \
    rm -rf /usr/src/* /tmp/* /etc/cron* && \
    apt-get purge -y $ASTERISK_BUILD_DEPS && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
### FreePBX hacks
    sed -i -e "s/memory_limit = 128M/memory_limit = 256M/g" /etc/php/${PHP_VERSION}/apache2/php.ini && \
    sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php/${PHP_VERSION}/apache2/php.ini && \
    a2disconf other-vhosts-access-log.conf && \
    a2enmod rewrite && \
    a2enmod headers && \
    rm -rf /var/log/* && \
    mkdir -p /var/log/asterisk && \
    mkdir -p /var/log/apache2 && \
    mkdir -p /var/log/httpd && \
    update-alternatives --set php /usr/bin/php${PHP_VERSION} && \
    chmod u+s /usr/sbin/crontab && \ 
### Zabbix setup
    echo '%zabbix ALL=(asterisk) NOPASSWD:/usr/sbin/asterisk' >> /etc/sudoers && \
### Setup for data persistence
    mkdir -p /assets/config/var/lib/ /assets/config/home/ && \
    mv /home/asterisk /assets/config/home/ && \
    ln -s /data/home/asterisk /home/asterisk && \
    mv /var/lib/asterisk /assets/config/var/lib/ && \
    ln -s /data/var/lib/asterisk /var/lib/asterisk && \
    ln -s /data/usr/local/fop2 /usr/local/fop2 && \
    mkdir -p /assets/config/var/run/ && \
    mv /var/run/asterisk /assets/config/var/run/ && \
#    mv /var/lib/mysql /assets/config/var/lib/ && \
    mkdir -p /assets/config/var/spool && \
    mkdir -p /var/spool/cron && \
    mv /var/spool/cron /assets/config/var/spool/ && \
    ln -s /data/var/spool/cron /var/spool/cron && \
#    mkdir -p /var/run/mongodb && \
#    rm -rf /var/lib/mongodb && \
#    ln -s /data/var/lib/mongodb /var/lib/mongodb && \
    ln -s /data/var/run/asterisk /var/run/asterisk && \
    rm -rf /var/spool/asterisk && \
    ln -s /data/var/spool/asterisk /var/spool/asterisk && \
    rm -rf /etc/asterisk && \
    ln -s /data/etc/asterisk /etc/asterisk && \
    ln -s /usr/sbin/crontab /usr/bin/crontab

### Networking configuration
EXPOSE 80 443 4445 4569 5060/udp 5160/udp 5061 5161 8001 8003 8008 8009 8025 ${RTP_START}-${RTP_FINISH}/udp

### Files add
ADD install /
