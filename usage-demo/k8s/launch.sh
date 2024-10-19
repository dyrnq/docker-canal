#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

kubectl apply -f https://ghp.ci/https://github.com/dyrnq/dist/raw/main/zookeeper/latest/10-deployments.yaml


sed \
-e "s@__CANAL_ZK__@zookeeper-0.zookeeper-headless.default.svc.cluster.local:2181,zookeeper-1.zookeeper-headless.default.svc.cluster.local:2181,zookeeper-2.zookeeper-headless.default.svc.cluster.local:2181@g" \
"${SCRIPT_DIR}/deployments.yaml" | \
kubectl apply -f -


# kubectl logs deployments/canal-server
