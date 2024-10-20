#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

kubectl apply -f https://ghp.ci/https://github.com/dyrnq/dist/raw/main/zookeeper/latest/10-deployments.yaml


kubectl apply -f ${SCRIPT_DIR}/deployments.yaml


# kubectl logs deployments/canal-server
