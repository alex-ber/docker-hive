#!/usr/bin/env bash

set -ex

/usr/sbin/sshd -D &

echo "starting fs"

$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
$HADOOP_PREFIX/sbin/start-dfs.sh

echo "creating folders"

$HADOOP_PREFIX/bin/hdfs dfs -mkdir /user /user/root /user/hive /user/hive/warehouse /tmp /tmp/hadoop-yarn /tmp/hadoop-yarn/staging
$HADOOP_PREFIX/bin/hdfs dfs -chmod 777 /tmp /user/hive/warehouse /tmp/hadoop-yarn /tmp/hadoop-yarn/staging

$HADOOP_PREFIX/sbin/hadoop-daemon.sh stop namenode
$HADOOP_PREFIX/sbin/stop-dfs.sh
