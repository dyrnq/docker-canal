# usage-demo

## docker-compose

compose为包含了

- zookeeper集群（zoo1，zoo2，zoo3）
- zoonavigator（zookeeper的web管理界面）
- canal-admin
- canal-admin-db（canal-admin的数据库）
- canal-server（cs1，cs2）
- main-db8 （mysql master，版本为bitnami/mysql:8.0.40-debian-12-r1）
- main-db5 （mysql master，版本为bitnami/mysql:5.7.43-debian-11-r73）
- adminer（mysql web管理界面）
- canal-admin-foo（canal-admin的foo集群初始化以及配置初始化）
- canal-adapter（ca1）

```bash
cd compose

# 启动
./launch.sh

# 停止
./launch.sh -r

# 停止并删除volumes
./launch.sh --rr

```

![architecture](https://a.dyrnq.com/2024-10-22_21-49.png "architecture diagram")

## k8s

k8s部署的集群并不包含canal-admin服务,直接使用k8s中的configmap共享配置

```bash
cd k8s

# 启动
./launch.sh

```

## 注意事项

- 以上都是demo，实际生产环境需要修改配置
- 以上是基于dyrnq/canal-server:1.1.8-alpha-3-jdk21版本
- 以上都使用了canal.serverMode=rocketMQ， 所以需要启动rocketMQ服务，测试中的192.168.88.123:9876是rocketMQ的地址，需要修改为实际的地址
- 以上都是用了zookeeper集群来存储canal的元数据
