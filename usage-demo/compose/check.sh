#!/usr/bin/env bash

container="${container:-main-db5}"
while [ $# -gt 0 ]; do
    case "$1" in
        --container|-c)
            container="$2"
            shift
            ;;
        --*)
            echo "Illegal option $1"
            ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done


ignore_Warning=" 2>/dev/null "

docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"show master status;\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"show slave hosts;\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW VARIABLES LIKE '%log_bin%';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW VARIABLES LIKE '%binlog%';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW VARIABLES LIKE '%slave%';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW BINARY LOGS;\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SELECT User, Host, plugin FROM mysql.user where User='canal';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SELECT User, Host, plugin FROM mysql.user where User='root';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW BINLOG EVENTS IN 'mysql-bin.000001' FROM 1\" ${ignore_Warning}"




