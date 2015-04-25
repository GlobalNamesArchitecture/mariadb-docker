MariaDB Docker
==============

[![Continuous Integration Status][1]][2]

General purpose **MariaDb v10.0** Docker Image. It is a derivative of a
[tutum-docker-mysql][3].  It supports replication, and has a [semisyncronous
replication][4] plugin installed.

Currently it creates one user for one database out of the box and an admin user
with root-like access.

Environment Variables
---------------------

Do make sure that container functions correcty include following variables to
your envifonment file:

### Common variables

Variable             | Description
---------------------|----------------------------------
`MDB_ADMIN_USER`     | superuser DEFAULT: `admin`
`MDB_ADMIN_PASSWORD` | superuser password NO DEFAULT
`MDB_USER`           | database user NO DEFAULT
`MDB_PASSWORD`       | database user password NO DEFAULT
`MDB_DB`             | database user database NO DEFAULT

### Replication variables

Variable                   | Description
---------------------------|---------------------------------------------------
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
  gnames/mariadb:10.0
```
Simplistic run:

```bash
$ sudo docker run -d -e MDB_ADMIN_PASSWORD=secret -p 3306:3306 --name mariadb gnames/mariadb:10.0
```
Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump
  version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


Copyright
---------

Author -- [Dmitry Mozzherin][5]


Copyright (c) 2015 [Marine Biological Laboratory][6]. See [LICENSE][7] for details.


[1]: https://circleci.com/gh/GlobalNamesArchitecture/mariadb-docker.svg?style=shield
[2]: https://circleci.com/gh/GlobalNamesArchitecture/mariadb-docker
[3]: https://github.com/tutumcloud/tutum-docker-mysql
[4]: https://dev.mysql.com/doc/refman/5.6/en/replication-semisync.html
[5]: https://github.com/dimus
[6]: http://mbl.edu
[7]: https://raw.githubusercontent.com/GlobalNamesArchitecture/mariadb-docker/master/LICENSE
