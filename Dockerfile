FROM ubuntu:14.04.2
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2015-04-25

RUN groupadd -f -g 301 -r mysql && \
    useradd -u 301 -g 301 -r -d "/nonexistent" -M -s "/bin/false" mysql && \
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    echo 'deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y mariadb-server pwgen vim-nox && \
    rm -rf /var/lib/mysql/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e "s/^bind-address.*$/bind-address = 0.0.0.0/" /etc/mysql/my.cnf && \
    rm -rf /var/lib/mysql/*

# Exposed ENV
ENV MDB_ADMIN_USER admin
ENV MDB_REPLICATION_ROLE none
ENV MDB_REPLICATION_USER replicator
ENV MDB_MASTER_PORT 3306
ENV TERM xterm-color

VOLUME /var/log
VOLUME /var/lib/mysql
VOLUME /etc/mysql
EXPOSE 3306

COPY start.sh /start.sh
COPY stop.sh /stop.sh
CMD ["/start.sh"]
