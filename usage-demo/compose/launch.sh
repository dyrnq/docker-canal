#!/usr/bin/env bash




DETACHED=${DETACHED:-}
while [ $# -gt 0 ]; do
    case "$1" in
        --detached|-d)
            DETACHED=1
            ;;
         --remove|-r)
            docker-compose down
            exit 0
            ;;
         --rr|-rr)
            docker-compose down --volumes
            exit 0
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

mkdir -p $HOME/sqls/admin-db
mkdir -p $HOME/sqls/main-db

curl -fSL -# -O --retry 10 https://ghp.ci/https://github.com/alibaba/canal/raw/master/docker/image/canal_manager.sql
mv -f -v canal_manager.sql $HOME/sqls/admin-db

cat > $HOME/sqls/main-db/init.sql <<EOF
CREATE USER canal IDENTIFIED BY 'canal';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
-- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
EOF

cat > $HOME/sqls/main-db/mytest2.sql <<'EOF'
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



mkdir -p $HOME/var/lib/zoo/zoo1/{datalog,data,logs}
mkdir -p $HOME/var/lib/zoo/zoo2/{datalog,data,logs}
mkdir -p $HOME/var/lib/zoo/zoo3/{datalog,data,logs}

mkdir -p $HOME/var/lib/cs1/logs
mkdir -p $HOME/var/lib/cs2/logs
mkdir -p $HOME/var/lib/cs3/logs


mkdir -p $HOME/var/lib/mysql/config

cat > $HOME/var/lib/mysql/config/mysqld.cnf <<EOF
[mysqld]
log-bin=mysql-bin # 开启 binlog
binlog-format=ROW # 选择 ROW 模式
server_id=1 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
EOF



if is_detached; then
    docker compose up -d
else
    docker compose up
fi
