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


ignore_Warning=" 2>/dev/vnull "

docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"show slave hosts;';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW VARIABLES LIKE '%binlog%';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW VARIABLES LIKE '%slave%';\" ${ignore_Warning}"
docker compose exec -it "${container}" bash -c "mysql -uroot --password=666666 -e \"SHOW BINARY LOGS;\" ${ignore_Warning}"



