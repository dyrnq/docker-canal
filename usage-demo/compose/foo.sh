#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)
api_host="http://127.0.0.1:18090"

if [ -f /.dockerenv ]; then
    echo "Running in a container (PID 1)"


    if [ -e /etc/apt/sources.list ]; then
    sed -i \
    -e 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' \
    -e 's@security.ubuntu.com@mirrors.ustc.edu.cn@g' /etc/apt/sources.list
    fi

    if [ -e /etc/apt/sources.list.d/ubuntu.sources ]; then
    sed -i \
    -e 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' \
    -e 's@security.ubuntu.com@mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources
    fi

    apt update;apt install httpie jq curl -y
    api_host="http://canal-admin:8090"
else
    echo "Not running in a container"
fi


echo "api_host=${api_host}"




login_api="${api_host}/api/v1/user/login"
cluster_clusters_api="${api_host}/api/v1/canal/clusters"
cluster_cluster_api="${api_host}/api/v1/canal/cluster"
cluster_config_api="${api_host}/api/v1/canal/config"
instance_api="${api_host}/api/v1/canal/instance"


while true; do
  curl -S -o /dev/null ${api_host} && token=$(http -j --ignore-stdin --session /tmp/canal.admin.session POST $login_api username=admin password=123456 | jq -r '.data.token') && echo "token=${token}" && break
done

if http -j --ignore-stdin --session /tmp/canal.admin.session GET $cluster_clusters_api X-Token:"${token}" | grep foo; then
    echo "cluster foo already exists"
else
    http -j --ignore-stdin --verbose --session /tmp/canal.admin.session POST $cluster_cluster_api name=foo zkHosts=zoo1:2181,zoo2:2181,zoo3:2181 X-Token:"${token}"
fi

## check main config exists

if [ "null" = "$(http -j --ignore-stdin --session /tmp/canal.admin.session GET "${cluster_config_api}/1/0" | jq -r '.data.id')" ]; then
http -j --ignore-stdin --verbose --session /tmp/canal.admin.session PUT $cluster_config_api clusterId=1 name=canal.properties content=@"${SCRIPT_DIR}"/canal.properties X-Token:"${token}"
else
  echo "cluster foo main config already exists"
fi

sleep 5s;

http -j --ignore-stdin --verbose --session /tmp/canal.admin.session POST $instance_api clusterServerId=cluster:1 name=test content=@"${SCRIPT_DIR}"/instance.properties X-Token:"${token}"

if [ -f /.dockerenv ]; then
  tail -f /dev/null
fi
