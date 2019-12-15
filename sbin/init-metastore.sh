#!/usr/bin/env bash

set -ex

rm -fr $HIVE_HOME/metastore_db
cd $HIVE_HOME && bin/schematool -initSchema -dbType derby
