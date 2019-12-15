#!/usr/bin/env bash

set -ex

bin=`cd "$(dirname $(which $0))" > /dev/null; pwd`

$bin/stop-hiveserver2.sh
$bin/init-metastore.sh
$bin/start-hiveserver2.sh 'javax.jdo.option.ConnectionURL=jdbc:derby:metastore_db;create=true'