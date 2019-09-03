# Docker-hive

EMR 5.25.0 cluster single node hadoop docker image. With Amzn linux, Hadoop 2.8.5 and Hive 2.3.5

## Prerequisites
Tested with

- Docker 18.09.2
- bash 3.2.57

## Contains
- Amazon Linux
- Java Open JDK 8
- Apache Hadoop 2.8.5
- Apache Hive 2.3.5
- Configuration Hadoop in a pseudo-distributed mode (Yarn in Single Node), 
see http://hadoop.apache.org/docs/r2.8.5/hadoop-project-dist/hadoop-common/SingleCluster.html for details. 

## Build

Clone repo

```
git clone git@gitlab.com:pursway-group/dev/dockefiles/docker-hive.git
```

Create image

```
docker build . -t alexberkovich/docker-hive
```

Or even, if you run the daemon with experimental features enabled: 

```
docker build --squash . -t alexberkovich/docker-hive
```

In Docker 1.13, a new --squash parameter was added. It can be used to reduce the size of an image by removing files 
which are not present anymore, and reduce multiple layers to a single one between the origin and the latest stage. 



You may want to do some cleanup first:

```
docker container stop local-hive; docker rm local-hive; docker rmi alexberkovich/docker-hive
```

## DockerHub

Image available on DockerHub

```
docker pull alexberkovich/docker-hive
```

## Test

`Enusre that you don't have running container

docker container stop local-hive; docker rm local-hive; 

Run image
```
docker-compose up -d
```

Or explicitly:

```
docker run -p 8030-8033:8030-8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p  -p 10000:10000 -p 10002:10002 -d --name local-hive alexberkovich/docker-hive
```


Wait for services started

```
docker logs local-hive
```

You can access bash with the following command

```
docker exec -it local-hive bash
```

Start beeline client and connect to hive:

```
/usr/local/hadoop/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p ""
```

Now you should be able to query

```
0: jdbc:hive2://localhost:10000> show databases;
+----------------+
| database_name  |
+----------------+
| default        |
+----------------+
1 row selected (1.921 seconds)
```


You can access YARN here http://localhost:8088/cluster

