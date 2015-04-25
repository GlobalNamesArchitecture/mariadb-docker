MariaDB Docker
==============

General purpose MariaDb v10.0 Docker Image. It is a derivative of a
[tutum-docker-mysql][1].  It supports replication, and has a [semisyncronous
replication][2] plugin installed.

Currently it creates one user for one database out of the box and an admin user
with root-like access.

Environment Variables
---------------------

Do make sure that container functions correcty include following variables to
your envifonment file:

### Common variables

`MDB_ADMIN_USER`     | superuser DEFAULT: `admin`
`MDB_ADMIN_PASSWORD` | superuser password NO DEFAULT
`MDB_USER`           | database user NO DEFAULT
`MDB_PASSWORD`       | database user password NO DEFAULT
`MDB_DB`             | database user database NO DEFAULT

### Replication variables

`MDB_REPLICATION_ROLE`     | set to `master`, `slave` or `none` DEFAULT: `none`
`MDB_MASTER_HOST`          | master IP for slaves NO DEFAULT
`MDB_MASTER_PORT`          | master's mariadb port for slaves DEFAULT: 3306
`MDB_REPLICATION_USER`     | replication user with limited privileges
`MDB_REPLICATION_PASSWORD` | replication user's password

Building docker image
---------------------

Execute from the project's root directory:

```bash
$ sudo docker build --rm -t gnames/mariadb .
```

Usage without replication
-------------------------

Run image with customized my.cnf and host volumes:

```bash
$ sudo docker run -d \
  --name mariadb \
  --env-file your_mariadb.env \
  -v some_path/myql:/var/lib/mysql \
  -v some_path/logs:/var/log/mariadb \
  -v some_path/my.cnf:/etc/mysql/my.cnf \
  -p 3306:3306 \
  gnames/mariadb
```
Simplistic run:

```bash
$ sudo docker run -d -e MDB_ADMIN_PASSWORD=secret -p 3306:3306 gnames/mariadb
```

[1]: https://github.com/tutumcloud/tutum-docker-mysql
[2]: https://dev.mysql.com/doc/refman/5.6/en/replication-semisync.html
