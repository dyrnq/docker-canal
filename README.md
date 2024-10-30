# docker-canal

[canal](https://github.com/alibaba/canal) is Alibaba's open source distributed database incremental subscription & consumption component. Based on long connections, it supports incremental data subscription and consumption, and also provides database incremental subscription and consumption based on the MySQL protocol.

- canal-server is the canal server.
- canal-admin is the canal management web ui.
- canal-adapter is the canal client adapter.

This project builds the docker images of each component of cannel and sorts out the related usage.

These images have the following features:

- base_image is eclipse-temurin(ubuntu noble).
- build with jdk8, jdk11, jdk17, jdk21.
- use gosu running that admin user which uid is 1000 and gid 1000.
- follow the image building principle and one container only does one thing, the last run java with pid=1(minor surgery on the original bin/startup.sh).
- supported version >=1.1.4. see tags [dyrnq/canal-server/tags](https://hub.docker.com/r/dyrnq/canal-server/tags).
- Please note that these images are not official images. However, they are compatible with official images.

## canal-server

canal-server is the canal server.

| Matters                          | Description                                                                                                                         |
|----------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| Image name                       | [dyrnq/canal-server](https://hub.docker.com/r/dyrnq/canal-server/tags)                                                              |
| Container entry point            | /docker-entrypoint.sh                                                                                                               |
| working dir                      | /home/admin/canal-server                                                                                                            |
| working uid/gid                  | 1000/1000                                                                                                                           |
| working user/group               | admin/admin                                                                                                                         |
| startup.sh                       | /home/admin/canal-server/bin/startup.sh                                                                                             |
| startup.sh github                | [deployer/src/main/bin/startup.sh](https://github.com/alibaba/canal/blob/master/deployer/src/main/bin/startup.sh)                   |
| conf/canal.properties            | canal running full configuration                                                                                                    |
| conf/canal_local.properties      | canal running partial configuration ( work with canal-admin)                                                                        |
| conf/example/instance.properties | [example/instance.properties](https://github.com/alibaba/canal/blob/master/deployer/src/main/resources/example/instance.properties) |

## canal-admin

canal-admin is the canal management web ui.

| Matters                           | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|-----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Image name                        | [dyrnq/canal-admin](https://hub.docker.com/r/dyrnq/canal-admin/tags)                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| Container entry point             | /docker-entrypoint.sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| working dir                       | /home/admin/canal-admin                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| working uid/gid                   | 1000/1000                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| working user/group                | admin/admin                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| startup.sh                        | /home/admin/canal-admin/bin/startup.sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| startup.sh github                 | [admin/admin-web/src/main/bin/startup.sh](https://github.com/alibaba/canal/blob/master/admin/admin-web/src/main/bin/startup.sh)                                                                                                                                                                                                                                                                                                                                                                                      |
| sql file                          | [canal_manager.sql](https://github.com/alibaba/canal/blob/master/docker/image/canal_manager.sql)                                                                                                                                                                                                                                                                                                                                                                                                                     |
| web login default user/passwd     | admin/123456                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| canal.adminUser/canal.adminPasswd | canal.adminUser/canal.adminPasswd  are canal-admin configuration.<br/><br/>canal.admin.user/canal.admin.passwd are canal-server configuration. <br/><br/>canal.admin.passwd need encryption see [alibaba/canal/wiki/Canal-Admin-ServerGuide#面向userpasswd的安全acl机制](https://github.com/alibaba/canal/wiki/Canal-Admin-ServerGuide#%E9%9D%A2%E5%90%91userpasswd%E7%9A%84%E5%AE%89%E5%85%A8acl%E6%9C%BA%E5%88%B6).<br/><br/>`canal.adminUser/canal.adminPasswd` and `canal.admin.user/canal.admin.passwd` need to match. |

e.g.

```sql
--- 密文的生成方式，请登录mysql，执行如下密文生成sql即可(记得去掉第一个首字母的星号)

select password('admin')

+-------------------------------------------+
| password('admin')                         |
+-------------------------------------------+
| *4ACFE3202A5FF5CF467898FC58AAB1D615029441 |
+-------------------------------------------+

--- 如果遇到mysql8.0，可以使用select upper(sha1(unhex(sha1('admin'))))
```

## canal-adapter

canal-adapter is the canal client adapter.

| Matters               | Description                                                                                                                                     |
|-----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
| Image name            | [dyrnq/canal-adapter](https://hub.docker.com/r/dyrnq/canal-adapter/tags)                                                                        |
| Container entry point | /docker-entrypoint.sh                                                                                                                           |
| working dir           | /home/admin/canal-adapter                                                                                                                       |
| working uid/gid       | 1000/1000                                                                                                                                       |
| working user/group    | admin/admin                                                                                                                                     |
| startup.sh            | /home/admin/canal-adapter/bin/startup.sh                                                                                                        |
| startup.sh github     | [client-adapter/launcher/src/main/bin/startup.sh](https://github.com/alibaba/canal/blob/master/client-adapter/launcher/src/main/bin/startup.sh) |


## image volume mount

| image name          | volume mount                                 |
|---------------------|----------------------------------------------|
| dyrnq/canal-server  | /home/admin/canal-server/{conf,logs,plugin}  |
| dyrnq/canal-admin   | /home/admin/canal-admin/{conf,logs}          |
| dyrnq/canal-adapter | /home/admin/canal-adapter/{conf,logs,plugin} |

Note that if the entire directory is mounted, the original files in the container will be overwritten. You can first copy the default files from the container and then mount them into the working container.

e.g.

```bash
docker run -itd --rm --name canal-tmp --entrypoint "" dyrnq/canal-server:1.1.8-alpha-3-jdk21 bash -c "tail -f /dev/null"
docker cp canal-tmp:/home/admin/canal-server/conf $(pwd)
docker rm -f canal-tmp 2>/dev/null || true
```

## HA

prerequisites:

- zookeeper.
- mysql.

### canal.instance.tsdb.enable=true

HA must use mysql replace default h2 tsdb configuration.

1. create mysql database canal_tsdb
2. create table from [deployer/src/main/resources/spring/tsdb/sql/create_table.sql](https://github.com/alibaba/canal/blob/master/deployer/src/main/resources/spring/tsdb/sql/create_table.sql)
3. update use mysql tsdb

```bash
canal.instance.tsdb.enable=true
canal.instance.tsdb.url=jdbc:mysql://<IP>:3306/canal_tsdb?useUnicode=true&characterEncoding=UTF-8&useSSL=false&serverTimezone=Asia/Shanghai
# canal.instance.tsdb.url=jdbc:mysql://<IP>:3306/canal_tsdb?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true
canal.instance.tsdb.dbUsername=canal
canal.instance.tsdb.dbPassword=canal
canal.instance.tsdb.spring.xml=classpath:spring/tsdb/mysql-tsdb.xml
```

### canal.instance.global.spring.xml

HA must use zookeeper, `canal.instance.global.spring.xml = classpath:spring/default-instance.xml` is using zookeeper, but not configed as default.

```bash
# canal.instance.global.spring.xml = classpath:spring/memory-instance.xml
# canal.instance.global.spring.xml = classpath:spring/file-instance.xml
canal.instance.global.spring.xml = classpath:spring/default-instance.xml
```

### HA with canal-admin

1. run canal-admin.
2. login canal-admin with user/password.
3. create cluster.
4. config main config for the cluster which step 3 created.
5. modify the main config which step 4 created. some key configs e.g. `canal.zkServers = zoo1:2181,zoo2:2181,zoo3:2181` `canal.serverMode = rocketMQ` `rocketmq.namesrv.addr = 192.168.88.123:9876`
6. add instance config and modify instance config. some key configs e.g. `canal.instance.master.address=main-db5:3306` `canal.instance.mysql.slaveId=`
7. run canal-server with *local* parameter. see [canal_local.properties](https://github.com/alibaba/canal/wiki/Canal-Admin-ServerGuide#%E5%8F%98%E5%8C%96%E7%82%B9)

### HA without canal-admin

1. configs all `canal.properties` for all the canal-server. see [canal.properties](https://github.com/alibaba/canal/blob/master/deployer/src/main/resources/canal.properties). 
2. keep the `canal.properties` configs same.
3. config instance configs for all the canal-server.
4. run canal-server.

### HA without zookeeper

if you don't want to use zookeeper.

1. you need to keep the `canal.properties` configs same,
2. use the same instance configs for all the canal-server. 
3. must use `Cloud Disk` to share the canal-server's data. e.g. `/home/admin/canal-server/conf/example/instance.properties` e.g. `/home/admin/canal-server/conf/example/meta.data`

### k8s

In k8s, there are two options, one is using a shared configmap(canal.properties) to configure each canal-server the same canal.properties, and another is using canal-admin.

## ref

- [alibaba/canal](https://github.com/alibaba/canal)
- [hub.docker.com/u/canal](https://hub.docker.com/u/canal)
