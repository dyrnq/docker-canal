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

cat > "${HOME}"/sqls/main-db5/mytest2.sql <<'EOF'
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `mytest2` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_bin */;
USE `mytest2`;
SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for canal_adapter_config
-- ----------------------------
DROP TABLE IF EXISTS `stuff`;
CREATE TABLE `stuff` (
    id INT PRIMARY KEY,
    name VARCHAR(50)
);


INSERT INTO stuff (id, name) VALUES
(1, 'Alice'),
(2, 'Bob'),
(3, 'Charlie'),
(4, 'David'),
(5, 'Eva'),
(6, 'Frank'),
(7, 'Grace'),
(8, 'Hannah'),
(9, 'Ivy'),
(10, 'Jack');


INSERT INTO stuff (id, name) VALUES
(11, 'Kathy'),
(12, 'Leo'),
(13, 'Mia'),
(14, 'Nina'),
(15, 'Oscar'),
(16, 'Paul'),
(17, 'Quincy'),
(18, 'Rachel'),
(19, 'Sam'),
(20, 'Tina'),
(21, 'Uma'),
(22, 'Victor'),
(23, 'Wendy'),
(24, 'Xander'),
(25, 'Yara'),
(26, 'Zane'),
(27, 'Amy'),
(28, 'Brian'),
(29, 'Cathy'),
(30, 'Derek');

EOF
cp -f -v "${HOME}"/sqls/main-db5/mytest2.sql "${HOME}"/sqls/main-db8/mytest2.sql


mkdir -p "${zoo1_dir}"/{datalog,data,logs}
mkdir -p "${zoo2_dir}"/{datalog,data,logs}
mkdir -p "${zoo3_dir}"/{datalog,data,logs}

mkdir -p "${HOME}"/var/lib/cs1/logs
mkdir -p "${HOME}"/var/lib/cs2/logs
mkdir -p "${HOME}"/var/lib/cs3/logs
mkdir -p "${HOME}"/var/lib/ca1/logs

mkdir -p "${HOME}"/var/lib/mysql/config

cat > "${HOME}"/var/lib/mysql/config/mysqld.cnf <<EOF
[mysqld]
log-bin=mysql-bin # 开启 binlog
binlog-format=ROW # 选择 ROW 模式
server_id=1 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
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




