#!/usr/bin/env bash

set -ex

/usr/sbin/sshd -D &

$HADOOP_PREFIX/sbin/hadoop-daemon.sh start namenode
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh

err_filename=$HADOOP_HOME/logs/hiveservier2_err.log
out_filename=$HADOOP_HOME/logs/hiveservier2_out.log

cd $HIVE_HOME && bin/schematool -initSchema -dbType derby
$HIVE_HOME/bin/hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console </dev/null > $out_filename  2> $err_filename &
tail -f /dev/null
