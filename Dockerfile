FROM ubuntu:14.04.1
MAINTAINER Dmitry Mozzherin
ENV LAST_FULL_REBUILD 2015-03-04
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
    echo 'deb http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.syringanetworks.net/mariadb/repo/10.0/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y mariadb-server pwgen && \
    rm -rf /var/lib/mysql/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Exposed ENV
ENV MYSQL_USER admin
ENV MYSQL_PASS **Random**

VOLUME /var/log
VOLUME /var/lib/mysql
VOLUME /etc/mysql
EXPOSE 3306

COPY start.sh /start.sh
COPY stop.sh /stop.sh
CMD ["/start.sh"]

