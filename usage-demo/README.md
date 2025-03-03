# usage-demo

## docker-compose

compose为包含了

- zookeeper集群（zoo1，zoo2，zoo3）
- zoonavigator（zookeeper的web管理界面）
- canal-admin
- canal-admin-db（canal-admin的数据库）
- canal-server（cs1，cs2）
- main-db5 （mysql source，版本为bitnami/mysql:5.7.43-debian-11-r73）
- replica-db5 （mysql dest，版本为bitnami/mysql:5.7.43-debian-11-r73）
- main-db8 （mysql source，版本为bitnami/mysql:8.0.40-debian-12-r2）
- replica-db8 （mysql dest，版本为bitnami/mysql:8.0.40-debian-12-r2）
- source-84 （mysql source，版本为bitnami/mysql:8.4.3-debian-12-r2）
- dest-84 （mysql dest，版本为bitnami/mysql:5.7.43-debian-11-r73）
- adminer（mysql web管理界面）
- canal-admin-foo（canal-admin的foo集群初始化以及配置初始化）
- canal-adapter（ca1）
- canal-sink-jdbc（[dyrnq/canal-sink-jdbc](https://github.com/dyrnq/canal-sink-jdbc)，使用rocketmq-spring-boot-starter消费canal-server产生的消息并sink到目标数据库）

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

k8s部署包含了如下两个选项,分别是不包含canal-admin和包含canal-admin的部署方式.

### optional configmap

using configmap share canal.properties

```bash
cd k8s

# 启动
./launch.sh

```

### optional canal-admin

using canal-admin share cluster`s canal.properties

```bash
cd k8s

# 启动
./launch.sh -a

```

## 注意事项

- 以上都是demo，实际生产环境需要修改配置
- 以上是基于dyrnq/canal-server:1.1.8-jdk21版本
- 以上都使用了canal.serverMode=rocketMQ， 所以需要启动rocketMQ服务，测试中的192.168.88.123:9876是rocketMQ的地址，需要修改为实际的地址
- 以上都是用了zookeeper集群来存储canal的元数据
