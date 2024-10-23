#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)



remove_flag=""
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


if [ "$remove_flag" = "" ]; then
    kubectl apply -f https://ghp.ci/https://github.com/dyrnq/dist/raw/main/zookeeper/latest/10-deployments.yaml
    kubectl apply -f ${SCRIPT_DIR}/deployments.yaml
else
    kubectl delete -f https://ghp.ci/https://github.com/dyrnq/dist/raw/main/zookeeper/latest/10-deployments.yaml
    kubectl delete -f ${SCRIPT_DIR}/deployments.yaml
fi



# kubectl logs deployments/canal-server
