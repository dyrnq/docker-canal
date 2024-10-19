# docker-canal

[cannel](https://github.com/alibaba/canal) is Alibaba's open source distributed database incremental subscription & consumption component. Based on long connections, it supports incremental data subscription and consumption, and also provides database incremental subscription and consumption based on the MySQL protocol.

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
- Note that these images is not an official mirror.

## canal-server

canal-server is the canal server.

| Matters               | Description                                                                                                       |
|-----------------------|-------------------------------------------------------------------------------------------------------------------|
| Image name            | [dyrnq/canal-server](https://hub.docker.com/r/dyrnq/canal-server/tags)                                            |
| Container entry point | /docker-entrypoint.sh                                                                                             |
| working dir           | /home/admin/canal-server                                                                                          |
| working uid/gid       | 1000/1000                                                                                                         |
| working user/group    | admin/admin                                                                                                       |
| startup.sh            | /home/admin/canal-server/bin/startup.sh                                                                           |
| startup.sh github     | [deployer/src/main/bin/startup.sh](https://github.com/alibaba/canal/blob/master/deployer/src/main/bin/startup.sh) |


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


## HA

prefabrication conditions:

- zookeeper.

### HA with canal-admin

1. run canal-admin.
2. login canal-admin with user/password.
3. create cluster.
4. config main config for the cluster which step 3 created.
5. modify the main config which step 4 created. some key configs e.g. `canal.zkServers = zoo1:2181,zoo2:2181,zoo3:2181` `canal.serverMode = rocketMQ` `rocketmq.namesrv.addr = 192.168.88.123:9876`
6. add instance config and modify instance config. some key configs e.g. `canal.instance.master.address=main-db5:3306`
7. run canal-server with *local* parameter. see [canal_local.properties](https://github.com/alibaba/canal/wiki/Canal-Admin-ServerGuide#%E5%8F%98%E5%8C%96%E7%82%B9)

### HA without canal-admin

1. configs all `canal.properties` for all the canal-server. see [canal.properties](https://github.com/alibaba/canal/blob/master/deployer/src/main/resources/canal.properties). 
2. keep the `canal.properties` configs same.
3. config instance configs for all the canal-server.
4. run canal-server.

## ref

- [alibaba/canal](https://github.com/alibaba/canal)
- [hub.docker.com/u/canal](https://hub.docker.com/u/canal)
