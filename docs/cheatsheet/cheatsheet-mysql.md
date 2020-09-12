# チートシート MySQL

- 参考
  - [south37: ISUCON Cheat Sheet](https://gist.github.com/south37/d4a5a8158f49e067237c17d13ecab12a)

## 設定ファイルの場所

OS の種類により置いてある場所が異なる．

- `/etc/mysql/my.conf`
- `/etc/mysql/conf.d/my.conf`
- `/etc/mysql/mysql.conf.d/mysqld.conf`

## バックアップ

## 知識

### /etc/mysql/my.conf と /etc/mysql/conf.d/my.conf の違い

- 参考：[What is the difference between my.cnf vs mysql.cnf?](https://stackoverflow.com/questions/43080687/what-is-the-difference-between-my-cnf-vs-mysql-cnf)

`/etc/mysql/my.conf` がグローバルな設定で，そのファイル内で `/etc/mysql/conf.d/` ディレクトリが include されている．

- `/etc/mysql/my.conf`

```conf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/
```

- `mysql.cnf` are the Ubuntu specific MySQL settings and `my.cnf` are the MySQL default settings.

The MySQL documentation contains a table describing what the various config files are supposed to be used for, but it doesn't mention mysql.cnf.

/etc/my.cnf Global options
/etc/mysql/my.cnf Global options
SYSCONFDIR/my.cnf Global options
\$MYSQL_HOME/my.cnf Server-specific options (server only)
defaults-extra-file The file specified with --defaults-extra-file, if any
~/.my.cnf User-specific options
~/.mylogin.cnf User-specific login path options (clients only)

- my.con
