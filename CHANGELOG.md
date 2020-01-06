# Changelog
All notable changes to this project will be documented in this file.


0.1.1
-----
Major

* Upgraded Hive to version 2.3.6


0.1.0
-----
Major
* BREAKING CHANGE: checkisup.sh is moved to $HADOOP_HOME/hive/sbin/ and this directory is added to PATH.

* BREAKING CHANGE: Hiveserver2 output logs to files, not to stdout & stderr.

It output to $HADOOP_HOME/logs/hiveservier2_out.log instead of stdout.

and to $HADOOP_HOME/logs/hiveservier2_err.log instead of stderr.

* Now, 

```
docker logs alex-local-hive
```

will not work.

* README.md changed, to reflect the change above. You should run

```
docker exec alex-local-hive checkisup.sh
```

to see whether Hiveserver2 is up.


* README.md changed, refer to container as alex-local-hive and not local-hive


Now, checkisup.sh is intended to be run 
```
docker exec alex-local-hive checkisup.sh
```

* docker-compose.yml modified, added container-name. 

* Added func.sh. It is intended for internal usage.

pdate  -  function that prints current timesatmp.

echoerr, echowarn, echoinfo - function that mimic logger output.

killit - takes process_id as parameter and send to it kill signal.

If it fails, send kill -9.

If it still fails, it will exit with return code 1.

findpid - helper function to find process_id. 

It takes as parameter string that will be used in grep in```ps aux```.

* Added script checkisup.sh.

Basically, this bash script is busy wait loop that tries to connect to the Hive service with Beeline (CLI tool to connect to Hive). It makes 10 different such attempts with sleep between them. In each attempt it wait for output from Beeline, if the output is not yet ready, there is 10 inner retires to read the output (with some sleep in-between). If it succeed than return code 0 is returned. If after 10 attempts, connection wasn't established, than return code non-zero is returned.


* Added script start-hiveserver2.sh
It is intended for internal usage.

There is 2 mode in which this script can be run:

Without any parameter. 

With parameter.

Basically, we’re looking for Hive process using ps utility and some identification string. If we found one, we first of all stop it.⁶

If start-hiveserver2.sh run without parameter, than we starting up Hive Server with existing Hive Metastore.

If start-hiveserver2.sh run with parameter (it is intended to be indication to create Hive Mestastore, but technically it can be anything) it will be passed through to hiveserver2.


* Added script stop-hiveserver2.sh
It is intended for internal usage.


Basically, we’re looking for Hive process using ps utility and some identification string, than we use kill -9.


* Added script init-metastore.sh
It is intended for internal usage.

It deletes metastore_db directory, and runs initSchema by schematool. It use Derby as storage. The data is stored in metastore_db directory.


Note:

init-metastore.sh can be technically run when Hive Service is up, but this should be avoided.

init-metastore.sh will not create Version table, etc (it is done when Hive Service is running up only).



* Added script reinit-metastore.sh

Intended usage is:

```
docker exec alex-local-hive reinit-metastore.sh
```

Note:

1.This script doesn’t format HDFS. So, you will have metastore and HDFS not in sync. See reinit-hdfs.sh above.

2.On mine machine this takes ~36 seconds. After this script finish to run, you Hive Service is available.


Basically, we stop Hive Server, then init metastore and then start Hive Server in the mode that create metastore_db


* Added script reinit-hdfs.sh

Intended usage is:

```
docker exec alex-local-hive reinit-hdfs.sh
```

Note:


1.This script doesn’t format metastore. So, you will have metastore and HDFS not in sync. See reinit-metasore.sh below.

2.On mine machine this takes ~70 seconds. After this script finish to run, you can use HDFS in regular way.

Basically, we stop all HDFS and Yarn services. We format namenode and remove all data from datanode, we remove another leftovers from previous run, than we resrart HDFS and Yarn service and recreate folders that Hive Service expect to be present.




For more detail explantaion see [https://medium.com/@alex_ber/docker-hive-scripts-52f7aa84bb7d](https://medium.com/@alex_ber/docker-hive-scripts-52f7aa84bb7d) 


0.0.6
-----
* Added script checkisup.sh. It is intented to be run as
```
docker exec alex-local-hive /etc/checkisup.sh
```
If it exit with return code 0, this means that HiveService2 is up and running.

If it exit with return code other than 0, there is some problem (see stderr).

If hiveservice is not yet running, this script will wait for it.

If after 10 retries HiveService2 is still not running, 

the script will give up (with non-zero return code).

0.0.5
-----
Minor
* Change README.md to reflect usage of private docker registry on Gitlab.
* Hive link changed.

0.0.4
-----
Major
* License added
* conf/yarn-site.xml added yarn.nodemanager.address set to localhost:9999

Minor
* Added docker-compose.yml and short description for it's usage

0.0.3
-----
Major
* Changing URL for hadoop & hive download.

Minor
* Setting fixed version for packages.
* "set -ex" added to dfs.sh
* "set -ex" added to run.sh

TBD
Tez
https://tez.apache.org/install.html
https://thecustomizewindows.com/2018/02/install-apache-tez-one-node-hadoop/
https://raw.githubusercontent.com/apache/incubator-tez/branch-0.2.0/INSTALL.txt

0.0.2
-----
Major
* conf/dfs.sh Removed $HADOOP_PREFIX/sbin/start-yarn.sh (it is useless here)
* conf/dfs.sh Added $HADOOP_PREFIX/sbin/start-dfs.sh (required)
* conf/dfs.sh Added hdfs dfs -chmod 777 /tmp/hadoop-yarn/staging 
(Required for impersonated Hive user to be able to start Map Reduce)
* conf/run.sh Added $HADOOP_PREFIX/sbin/start-dfs.sh (was missing, required)
* conf/mapres-site.xml added mapreduce.map.memory.mb, mapreduce.map.java.opts, mapreduce.reduce.java.opts.
Otherwise, when MapReduce works it crushes JVM. Even hadoop-mapreduce-examples-2.8.5.jar don't work. See https://community.cloudera.com/t5/Support-Questions/Map-and-Reduce-Error-Java-heap-space/td-p/45874
* Hadoop “Unable to load native-hadoop library for your platform” warning fixed (added ENV LD_LIBRARY_PATH) 
(major performance impact)


Minor
* conf/run.sh copies to /etc/run.sh (and not to root)
* conf/core-site.xml fs.default.name key changed to fs.defaultFS
* conf/hdfs-site.xml dfs.name.dir key changed to fs.namenode.name.dir 
* conf/hdfs-site.xml dfs.data.dir key changed to dfs.datanode.data.dir
* In Dockerfile Added nano
* LICENSE.txt added
* CHANGELOG.md is added