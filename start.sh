#!/bin/bash

VOLUME_HOME="/var/lib/mysql"
CONF_FILE="/etc/mysql/my.cnf"
LOG="/var/log/mysql/error.log"

StartMySQL ()
{
  /usr/bin/mysqld_safe > /dev/null 2>&1 &

  LOOP_LIMIT=13
  echo "========================================================================" >> ${LOG}
  for (( i=0 ; ; i++ )); do
    if [ ${i} -eq ${LOOP_LIMIT} ]; then
      echo "Time out. Error log is shown as below:" >> ${LOG}
      exit 1
    fi
    echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..." >> ${LOG}
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1 && break
  done
  echo "========================================================================" >> ${LOG}
}

CreateMySQLUsers ()
{
  StartMySQL
  ADMIN=${MDB_ADMIN_USER}
  ADMIN_PASS=${MDB_ADMIN_PASSWORD}
  USER=${MDB_USER}
  USER_PASS=${MDB_PASSWORD}
  DB=${MDB_DB}

  echo "========================================================================" >> ${LOG}
  echo "Creating '${ADMIN}' user ..." >> ${LOG}
  mysql -uroot -e "CREATE USER '${ADMIN}'@'%' IDENTIFIED BY '${ADMIN_PASS}'"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN}'@'%' WITH GRANT OPTION"
  if [ "${USER}" != "" -a "${USER_PASSWORD}" != "" -a "${DB}" != "" ]; then
    echo "Creating ${USER} user ..." >> ${LOG}
    mysql -uroot -e "CREATE USER '${USER}'@'%' IDENTIFIED BY '${USER_PASS}'"
    mysql -uroot -e "GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'%' WITH GRANT OPTION"
  fi

  echo "=> Done!" >> ${LOG}

  echo "You can now connect to this MySQL Server using:" >> ${LOG}
  echo "" >> ${LOG}
  echo "    mysql -u$ADMIN -p -h<host> -P<port>" >> ${LOG}
  echo ""
  echo "========================================================================" >> ${LOG}

  mysqladmin -uroot shutdown
}

if [[ ! -d $VOLUME_HOME/mysql ]]; then
  echo "========================================================================" >> ${LOG}
  echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME" >> ${LOG}
  echo "=> Installing MySQL ..." >> ${LOG}
  if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
    cp $CONF_FILE /usr/share/mysql/my-default.cnf
  fi
  mysql_install_db --user=mysql --ldata=/var/lib/mysql/
  echo "=> Done!" >> ${LOG}
  echo "========================================================================" >> ${LOG}
  CreateMySQLUsers
else
  echo "=> Using an existing volume of MySQL" >> ${LOG}
fi

# Set MySQL REPLICATION - MASTER
if [ "${MDB_REPLICATION_ROLE}" == "master" ]; then
  echo "========================================================================" >> ${LOG}
  echo "=> Configuring MySQL replication as master ..." >> ${LOG}
  if [ ! -f $VOLUME_HOME/replication_configured ]; then
    echo "=> Starting MySQL ..." >> ${LOG}
    StartMySQL
    echo "=> Creating a log user ${MDB_REPLICATION_USER}:${MDB_REPLICATION_PASSWORD}"
    mysql -uroot -e "CREATE USER '${MDB_REPLICATION_USER}'@'%' IDENTIFIED BY '${MDB_REPLICATION_PASSWORD}'"
    mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO '${MDB_REPLICATION_USER}'@'%'"
    echo "=> Install semi-syncronous replication plugin on master" >> ${LOG}
    mysql -uroot -e "INSTALL PLUGIN rpl_semi_sync_master SONAME 'semisync_master.so'"
    echo "=> Done!" >> ${LOG}
    mysqladmin -uroot shutdown
    touch $VOLUME_HOME/replication_configured
  else
    echo "=> MySQL replication master already configured, skip" >> ${LOG}
  fi
  echo "========================================================================" >> ${LOG}
fi

# Set MySQL REPLICATION - SLAVE
if [ "${MDB_REPLICATION_ROLE}" == "slave" ]; then
  echo "========================================================================" >> ${LOG}
  echo "=> Configuring MySQL replication as slave ..." >> ${LOG}
  if [ ! -f $VOLUME_HOME/replication_configured ]; then
    RAND="$(date +%s | rev | cut -c 1-2)$(echo ${RANDOM})" >> ${LOG}
    echo "=> Starting MySQL ..." >> ${LOG}
    StartMySQL
    echo "=> Setting master connection info on slave" >> ${LOG}
    mysql -uroot -e "CHANGE MASTER TO MASTER_HOST='${MDB_MASTER_HOST}',MASTER_USER='${MDB_REPLICATION_USER}',MASTER_PASSWORD='${MDB_REPLICATION_PASSWORD}',MASTER_PORT=${MDB_MASTER_PORT}, MASTER_CONNECT_RETRY=30"
    echo "=> Install semi-syncronous replication plugin on slave" >> ${LOG}
    mysql -uroot -e "INSTALL PLUGIN rpl_semi_sync_slave SONAME 'semisync_slave.so'"
    echo "=> Done!" >> ${LOG}
    mysqladmin -uroot shutdown
    touch $VOLUME_HOME/replication_configured
  else
    echo "=> MySQL replicaiton slave already configured, skip" >> ${LOG}
  fi
  echo "========================================================================" >> ${LOG}
fi

tail -F $LOG &
chmod a+rx /
chown mysql:mysql -R /var/lib/mysql
chown mysql:mysql -R /var/log/mysql
exec mysqld_safe
