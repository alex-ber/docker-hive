#!/usr/bin/env bash

set -ex

echo "Stoping dfs and yarn, formatting filesystem"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh stop namenode
$HADOOP_PREFIX/sbin/stop-dfs.sh
$HADOOP_PREFIX/sbin/stop-yarn.sh

echo "Formatting filesystem"
rm -rf /tmp/hadoop-root/ /tmp/hsperfdata_root /tmp/*_resources /home/hadoop/hadoopdata/
$HADOOP_PREFIX/bin/hdfs namenode -format -force
#$HADOOP_PREFIX/bin/hdfs dfs -rm -f -R /user /tmp -skipTrash


echo "Starting dfs and yarn"
$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh
#$HADOOP_PREFIX/bin/hdfs dfsadmin -safemode leave

echo "creating folders"
$HADOOP_PREFIX/bin/hdfs dfs -mkdir /user /user/root /user/hive /user/hive/warehouse /tmp /tmp/hadoop-yarn /tmp/hadoop-yarn/staging
$HADOOP_PREFIX/bin/hdfs dfs -chmod 777 /tmp /user/hive/warehouse /tmp/hadoop-yarn /tmp/hadoop-yarn/staging

