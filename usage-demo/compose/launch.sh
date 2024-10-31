#!/usr/bin/env bash


SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)


zoo1_dir="${HOME}"/var/lib/zoo/zoo1
zoo2_dir="${HOME}"/var/lib/zoo/zoo2
zoo3_dir="${HOME}"/var/lib/zoo/zoo3

remove_flag=""
DETACHED=${DETACHED:-}
while [ $# -gt 0 ]; do
    case "$1" in
        --detached|-d)
            DETACHED=1
            ;;
         --remove|-r)
            remove_flag="1";
            ;;
         --rr|-rr)
            remove_flag="2"
            ;;
        --*)
            echo "Illegal option $1"
            ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done


is_detached() {
    if [ -z "$DETACHED" ]; then
        return 1
    else
        return 0
    fi
}

init_containers() {

docker network inspect canal &>/dev/null || docker network create --subnet 172.224.0.0/16 --gateway 172.224.0.1 --driver bridge canal

mkdir -p "${HOME}"/sqls/admin-db
mkdir -p "${HOME}"/sqls/main-db5
mkdir -p "${HOME}"/sqls/main-db8

mkdir -p "${HOME}"/sqls/replica-db5
mkdir -p "${HOME}"/sqls/replica-db8

mkdir -p "${HOME}"/sqls/source-84
mkdir -p "${HOME}"/sqls/dest-84

mkdir -p "${HOME}"/var/lib/canal-admin-foo

curl -fSL -# -O --retry 10 https://ghp.ci/https://github.com/alibaba/canal/raw/master/docker/image/canal_manager.sql
mv -f -v canal_manager.sql "${HOME}"/sqls/admin-db

cp -f -v "${SCRIPT_DIR}"/foo.sh "${HOME}"/var/lib/canal-admin-foo/foo.sh
cp -f -v "${SCRIPT_DIR}"/canal.properties "${HOME}"/var/lib/canal-admin-foo/canal.properties
cp -f -v "${SCRIPT_DIR}"/instance.properties "${HOME}"/var/lib/canal-admin-foo/instance.properties

curl -fSL -# -O --retry 10 https://ghp.ci/https://github.com/alibaba/canal/blob/master/deployer/src/main/resources/spring/tsdb/sql/create_table.sql

cat <(cat <<'EOF'
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `canal_tsdb` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;

USE `canal_tsdb`;
GRANT ALL PRIVILEGES ON `canal\_tsdb`.* TO `canal`@`%`;
GRANT ALL PRIVILEGES ON `canal\_manager`.* TO `canal`@`%`;

FLUSH PRIVILEGES;
SHOW GRANTS FOR 'canal'@'%';
SET NAMES utf8;
EOF
) create_table.sql > "${HOME}"/sqls/admin-db/canal_tsdb.sql
rm -rf create_table.sql


cat > "${HOME}"/sqls/main-db5/init.sql <<EOF
CREATE USER canal IDENTIFIED BY 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
EOF

cat > "${HOME}"/sqls/main-db8/init.sql <<EOF
-- CREATE USER canal IDENTIFIED BY 'canal';
CREATE USER canal IDENTIFIED WITH mysql_native_password BY 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
EOF


cat > "${HOME}"/sqls/source-84/init.sql <<EOF
-- CREATE USER canal IDENTIFIED BY 'canal';
CREATE USER canal IDENTIFIED WITH mysql_native_password BY 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
EOF

# ERROR 1396 (HY000) at line 1 in file: '/docker-entrypoint-initdb.d/init.sql': Operation CREATE USER failed for 'canal'@'%'
# mysql 06:53:47.19 ERROR ==> Failed executing /docker-entrypoint-initdb.d/init.sql

rm -rf "${HOME}"/sqls/main-db5/mytest2.sql
rm -rf "${HOME}"/sqls/main-db8/mytest2.sql
rm -rf "${HOME}"/sqls/replica-db5/mytest2.sql
rm -rf "${HOME}"/sqls/replica-db8/mytest2.sql

cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/main-db5/
cp -f -v "${SCRIPT_DIR}"/mytest2-101-data.sql "${HOME}"/sqls/main-db5/
cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/main-db8/
cp -f -v "${SCRIPT_DIR}"/mytest2-101-data.sql "${HOME}"/sqls/main-db8/
cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/source-84/
cp -f -v "${SCRIPT_DIR}"/mytest2-101-data.sql "${HOME}"/sqls/source-84/

cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/replica-db5/
cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/replica-db8/
cp -f -v "${SCRIPT_DIR}"/mytest2-100-schema.sql "${HOME}"/sqls/dest-84/


mkdir -p "${zoo1_dir}"/{datalog,data,logs}
mkdir -p "${zoo2_dir}"/{datalog,data,logs}
mkdir -p "${zoo3_dir}"/{datalog,data,logs}

mkdir -p "${HOME}"/var/lib/cs1/logs
mkdir -p "${HOME}"/var/lib/cs2/logs
mkdir -p "${HOME}"/var/lib/cs3/logs
mkdir -p "${HOME}"/var/lib/ca1/logs

mkdir -p "${HOME}"/var/lib/main-db5/config
mkdir -p "${HOME}"/var/lib/main-db8/config
mkdir -p "${HOME}"/var/lib/replica-db5/config
mkdir -p "${HOME}"/var/lib/replica-db8/config
mkdir -p "${HOME}"/var/lib/source-84/config
mkdir -p "${HOME}"/var/lib/dest-84/config
mkdir -p "${HOME}"/var/lib/canal-admin-db/config


cat > "${HOME}"/var/lib/main-db5/config/mysqld.cnf <<EOF
[mysqld]
log-bin=mysql-bin
binlog-format=ROW
server_id=1
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
# binlog_rows_query_log_events = 1
# MySQL 5.6.2 introduces two parameters: binlog_rows_query_log_events and binlog_row_image
# binlog_row_image = 'full'
# binlog_row_image = 'minimal'
EOF

cat > "${HOME}"/var/lib/main-db8/config/mysqld.cnf <<EOF
[mysqld]
log-bin=mysql-bin
binlog-format=ROW
server_id=1
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
binlog_row_image = FULL
binlog_row_metadata = FULL
EOF

cat > "${HOME}"/var/lib/source-84/config/mysqld.cnf <<EOF
[mysqld]
log-bin=mysql-bin
binlog-format=ROW
server_id=1
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
binlog_row_image = FULL
binlog_row_metadata = FULL
mysql_native_password=ON
# mysql 8.4
EOF

# 2024-10-31T06:57:38.365301Z 0 [ERROR] [MY-000067] [Server] unknown variable 'mysql_native_password=ON'.

cat > "${HOME}"/var/lib/replica-db5/config/mysqld.cnf <<EOF
[mysqld]
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
EOF

cat > "${HOME}"/var/lib/replica-db8/config/mysqld.cnf <<EOF
[mysqld]
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
EOF

cat > "${HOME}"/var/lib/dest-84/config/mysqld.cnf <<EOF
[mysqld]
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
EOF

cat > "${HOME}"/var/lib/canal-admin-db/config/mysqld.cnf <<EOF
[mysqld]
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_ci
default_time_zone = '+08:00'
EOF


cat >"${HOME}"/var/logback.xml<<'EOF'
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="info">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
EOF
}

if [ "$remove_flag" = "1" ]; then
    echo "will remove all containers, docker-compose down"
    docker-compose down
elif [ "$remove_flag" = "2" ]; then
    echo "will remove all containers and data, docker-compose down --volumes"

    rm -rfv "${zoo1_dir}"
    rm -rfv "${zoo2_dir}"
    rm -rfv "${zoo3_dir}"
    docker-compose down --volumes
else


  init_containers

  if is_detached; then
      docker compose up -d
  else
      docker compose up
  fi

fi




