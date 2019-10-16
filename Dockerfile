FROM amazonlinux

RUN yum install -y openssh-7.4p1-16.amzn2.0.6 \
    openssh-clients-7.4p1-16.amzn2.0.6 \
    openssh-server-7.4p1-16.amzn2.0.6 \
    which-2.20-7.amzn2.0.2 \
    procps-ng-3.3.10-17.amzn2.2.2 \
    tar-1.26-34.amzn2 \
    curl-7.61.1-11.amzn2.0.2 \
    wget-1.14-18.amzn2.1 \
    net-tools-2.0-0.22.20131004git.amzn2.0.2 \
    nano-2.9.8-2.amzn2.0.1

#disable coloring for nano, see https://stackoverflow.com/a/55597765/1137529
RUN echo "syntax \"disabled\" \".\"" > ~/.nanorc; echo "color green \"^$\"" >> ~/.nanorc

#work-arround for nano
#Odd caret/cursor behavior in nano within SSH session,
#see https://github.com/Microsoft/WSL/issues/1436#issuecomment-480570997
ENV TERM eterm-color


# setup ssh, see http://hadoop.apache.org/docs/r2.8.5/hadoop-project-dist/hadoop-common/SingleCluster.html
RUN ssh-keygen -A
RUN ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
COPY conf/ssh_config /root/.ssh/config
RUN chmod 0600 ~/.ssh/authorized_keys ~/.ssh/config

# install java
RUN yum install java-1.8.0-openjdk-1.8.0.201.b09-0.amzn2 -y
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk/
ENV JAVA_PATH $JAVA_HOME
ENV PATH $PATH:$JAVA_HOME/bin

# install hadoop
RUN wget http://apache.mivzakim.net/hadoop/common/hadoop-2.8.5/hadoop-2.8.5.tar.gz
RUN tar -xzf hadoop-2.8.5.tar.gz -C /usr/local/
RUN cd /usr/local && ln -s ./hadoop-2.8.5 hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_PREFIX $HADOOP_HOME
ENV HADOOP_INSTALL $HADOOP_HOME
ENV HADOOP_MAPRED_HOME $HADOOP_HOME
ENV HADOOP_COMMON_HOME $HADOOP_HOME
ENV HADOOP_HDFS_HOME $HADOOP_HOME
ENV YARN_HOME $HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR $HADOOP_HOME/lib/native
ENV LD_LIBRARY_PATH $HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH
ENV PATH $PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin


# config hadoop
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk/:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
COPY conf/core-site.xml /usr/local/hadoop/etc/hadoop/core-site.xml
COPY conf/hdfs-site.xml /usr/local/hadoop/etc/hadoop/hdfs-site.xml
COPY conf/mapred-site.xml /usr/local/hadoop/etc/hadoop/mapred-site.xml
COPY conf/yarn-site.xml /usr/local/hadoop/etc/hadoop/yarn-site.xml

#install hive
#RUN wget http://mirror.apache-kr.org/hive/hive-2.3.5/apache-hive-2.3.5-bin.tar.gz
RUN wget https://archive.apache.org/dist/hive/hive-2.3.5/apache-hive-2.3.5-bin.tar.gz
RUN tar -xzf apache-hive-2.3.5-bin.tar.gz -C /usr/local/hadoop/
RUN cd /usr/local/hadoop && ln -s ./apache-hive-2.3.5-bin hive
ENV HIVE_HOME $HADOOP_HOME/hive

RUN chown -R root:root /usr/local/hadoop-2.8.5
RUN $HADOOP_PREFIX/bin/hdfs namenode -format
COPY ./dfs.sh /etc/dfs.sh

RUN /etc/dfs.sh

COPY ./run.sh /etc/run.sh
#COPY ./alex_hive_udf.jar ${HIVE_HOME}/auxlib/alex_hive_udf.jar

# clean
RUN rm hadoop-2.8.5.tar.gz apache-hive-2.3.5-bin.tar.gz

CMD ["/etc/run.sh"]

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Hive ports
EXPOSE 10000 10002


#docker rmi -f alex-docker-hive
#docker rm -f alex-local-hive
#docker build --squash . -t alex-docker-hive
#docker run -p 8030-8033:8030-8033 -p 8040:8040 -p 8042:8042 -p 8088:8088 -p 10000:10000 -p 10002:10002 -d --name alex-local-hive alex-docker-hive
#docker exec -it $(docker ps -q -n=1) bash
#docker tag alex-docker-hive registry.gitlab.com/pursway-group/dev/dockerfiles/docker-hive:0.0.5
#docker push registry.gitlab.com/pursway-group/dev/dockerfiles/docker-hive:0.0.5


