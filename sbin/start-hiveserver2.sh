#!/usr/bin/env bash

bin=`cd "$(dirname $(which $0))" > /dev/null; pwd`

source $bin/func.sh

err_filename=$HADOOP_HOME/logs/hiveservier2_err.log
out_filename=$HADOOP_HOME/logs/hiveservier2_out.log

set -e

pid=$(findpid "[j]ava[[:blank:]]-Xmx256m[[:blank:]]-Djava.net.preferIPv4Stack=true")
if [ -n "$pid" ]; then echowarn "Hiveserver2 is aready up. Stopping it";  $bin/stop-hiveserver2.sh; fi

param=$@

if [ -z "$param" ];
then
   connection_url="javax.jdo.option.ConnectionURL=jdbc:derby:metastore_db"
else
   connection_url=$param
fi

echoinfo $connection_url


cd $HIVE_HOME
$HIVE_HOME/bin/hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console \
                                                     $connection_url \
                                                     </dev/null > $out_filename  2> $err_filename &



