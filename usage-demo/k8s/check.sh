#!/usr/bin/env bash


kubectl exec -it canal-server-0 -- bash -c "env |grep ^canal"
kubectl exec -it canal-server-0 -- bash -c "apt update;apt install netcat-openbsd inetutils-ping -y;"
kubectl exec -it canal-server-0 -- bash -c "ping -c 3 canal-server-1.canal-server-headless.default.svc.cluster.local"
kubectl exec -it canal-server-0 -- bash -c "nc -vz canal-server-1.canal-server-headless.default.svc.cluster.local 11110"


