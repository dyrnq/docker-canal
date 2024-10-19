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

| Matters               | Description                                                                                                                     |
|-----------------------|---------------------------------------------------------------------------------------------------------------------------------|
| Image name            | [dyrnq/canal-admin](https://hub.docker.com/r/dyrnq/canal-admin/tags)                                                           |
| Container entry point | /docker-entrypoint.sh                                                                                                           |
| working dir           | /home/admin/canal-admin                                                                                                         |
| working uid/gid       | 1000/1000                                                                                                                       |
| working user/group    | admin/admin                                                                                                                     |
| startup.sh            | /home/admin/canal-admin/bin/startup.sh                                                                                          |
| startup.sh github     | [admin/admin-web/src/main/bin/startup.sh](https://github.com/alibaba/canal/blob/master/admin/admin-web/src/main/bin/startup.sh) |
| sql file              | [canal_manager.sql](https://github.com/alibaba/canal/blob/master/docker/image/canal_manager.sql)                                |

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


## ref

- [alibaba/canal](https://github.com/alibaba/canal)
- [hub.docker.com/u/canal](https://hub.docker.com/u/canal)
