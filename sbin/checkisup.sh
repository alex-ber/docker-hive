#!/usr/bin/env bash

bin=`cd "$(dirname $(which $0))" > /dev/null; pwd`
source $bin/func.sh


line_success=
line=
err_filename=$HADOOP_HOME/logs/beeline_err.log
out_filename=$HADOOP_HOME/logs/beeline_out.log
PID=
should_countiune=

for i in {1..10};
do
 echoinfo 'Starting'

 sleep 1s

 /usr/local/hadoop/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p "" </dev/null > $out_filename  2> $err_filename &
 rc=$?
 PID=$!
 # if [ "$rc" -ne 0 ]; then cleanup; echo "beeline return code is not 0" >&2; exit $rc; fi
 if [ "$rc" -ne 0 ]; then echoerr "beeline return code is not 0" ; exit $rc; fi

 for j in {1..10};
  do
   sleep 7s
   line_success=$(grep -w $out_filename -e 'jdbc:hive2://*')
   if [ -n "$line_success" ]; then echoinfo $line_success; exit 0; fi

   line=$(grep -w $out_filename -e 'beeline')
   if [ -n "$line" ]; then echoinfo "Not ready yet."; should_continue='true'; break; fi
   echoinfo "Rereading output...$j"
 done

 if [ -n $should_continue ]; then echoinfo "Retrying...$i"; continue; fi;
 #if [ $j -ge 10]; then echo "Retries of rereading output is exhasting. Sorry..."; cleanup; exit 3; fi
 if [ $j -ge 10 ]; then echowarn "Retries of rereading output is exhasting. Sorry..."; exit 3; fi

 line=$(grep -w $err_filename -e 'Error')
 #if [ -n "$line" ]; then echo $line; cleanup; fi
 if [ -n "$line" ]; then echoinfo $line; fi
done

if [ $i -ge 10 ]; then echowarn "$i Retries are exhasting. Sorry..."; exit 7; fi