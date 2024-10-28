#!/usr/bin/env bash

docker compose exec -it main-db5 bash -c "mysqladmin variables -uroot --password=666666 2>/dev/null| grep binlog | sort" > 5-binlog.txt

docker compose exec -it main-db8 bash -c "mysqladmin variables -uroot --password=666666 2>/dev/null| grep binlog | sort" > 8-binlog.txt


for i in 5 8; do
tail /dev/null >${i}-binlog.properties
touch ${i}-binlog.properties


while IFS= read -r line; do
variable_key=$(echo "$line" | awk -F '|' '{print $2}' | xargs)
variable_value=$(echo "$line" | awk -F '|' '{print $3}' | xargs)
echo "$variable_key=$variable_value" >> ${i}-binlog.properties
done < ${i}-binlog.txt


done

diff -y 5-binlog.properties 8-binlog.properties

rm -rf 5-binlog.properties
rm -rf 8-binlog.properties
rm -rf 5-binlog.txt
rm -rf 8-binlog.txt
