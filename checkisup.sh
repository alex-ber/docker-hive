#!/usr/bin/env bash

line_success=
line=
err_filename=$HADOOP_HOME/logs/beeline_err.log
out_filename=$HADOOP_HOME/logs/beeline_out.log
PID=
should_countiune=

cleanup() {
 #killing beeling
 disown $PID
 kill $PID
 sleep 2s
 # if process is still around, use kill -9
 if ps -p $PID > /dev/null ; then
     echo "Initial kill failed, getting serious now..." >&2
     kill -9 $PID

 fi
 if ps -p $PID > /dev/null ; then
      echo "Wow, even kill -9 failed, giving up; sorry" >&2
      exit 1
 fi
}



for i in {1..10};
do
 echo 'Starting'

 sleep 1s

 /usr/local/hadoop/hive/bin/beeline -u jdbc:hive2://localhost:10000 -n "" -p "" </dev/null > $out_filename  2> $err_filename &
 rc=$?
 PID=$!
 # if [ "$rc" -ne 0 ]; then cleanup; echo "beeline return code is not 0" >&2; exit $rc; fi
 if [ "$rc" -ne 0 ]; then echo "beeline return code is not 0" >&2; exit $rc; fi

 for j in {1..10};
  do
   sleep 7s
   line_success=$(grep -w $out_filename -e 'jdbc:hive2://*')
   if [ -n "$line_success" ]; then echo $line_success; exit 0; fi

   line=$(grep -w $out_filename -e 'beeline')
   if [ -n "$line" ]; then echo "Not ready yet."; should_continue='true'; break; fi
   echo "Rereading output...$j"
 done

 if [ -n $should_continue ]; then echo "Retrying...$i"; continue; fi;
 #if [ $j -ge 10]; then echo "Retries of rereading output is exhasting. Sorry..."; cleanup; exit 3; fi
 if [ $j -ge 10 ]; then echo "Retries of rereading output is exhasting. Sorry..."; exit 3; fi

 line=$(grep -w $err_filename -e 'Error')
 #if [ -n "$line" ]; then echo $line; cleanup; fi
 if [ -n "$line" ]; then echo $line; fi
done

if [ $i -ge 10 ]; then echo "$i Retries are exhasting. Sorry..."; exit 7; fi

