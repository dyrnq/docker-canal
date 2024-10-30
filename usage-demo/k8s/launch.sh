#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)



remove_flag=""
canal_admin=""
while [ $# -gt 0 ]; do
    case "$1" in
        --with-admin|-a)
            canal_admin="1";
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

    if [ "$canal_admin" = "1" ]; then
        kubectl apply -f ${SCRIPT_DIR}/optional-canal-admin.yaml
    else
        kubectl apply -f ${SCRIPT_DIR}/optional-configmap.yaml
    fi

else
    kubectl delete -f https://ghp.ci/https://github.com/dyrnq/dist/raw/main/zookeeper/latest/10-deployments.yaml
    kubectl delete -f ${SCRIPT_DIR}/deployments.yaml
    kubectl delete -f ${SCRIPT_DIR}/optional-canal-admin.yaml
    kubectl delete -f ${SCRIPT_DIR}/optional-configmap.yaml
fi



# kubectl logs deployments/canal-server
