#!/usr/bin/env bash

bin=`cd "$(dirname $(which $0))" > /dev/null; pwd`
source $bin/func.sh

set -e

pid=$(findpid "[j]ava[[:blank:]]-Xmx256m[[:blank:]]-Djava.net.preferIPv4Stack=true")
if [ -z "$pid" ]; then echoerr "Hiveserver2 process not found"; exit 1; fi
killit $pid