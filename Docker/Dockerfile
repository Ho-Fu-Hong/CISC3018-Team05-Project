FROM apache/spark:3.5.0
USER root

# Install dependencies including OpenJDK
RUN apt-get update && apt-get install -y \
	wget \
	ssh \
	openssh-server \
	python3-pip \
	vim \
	netcat-openbsd \
	sudo \
	openjdk-17-jdk \
	&& rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
	
# Download and install Hadoop
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz && \
	tar -xzf hadoop-3.3.6.tar.gz -C /opt/ && \
	rm hadoop-3.3.6.tar.gz && \
	ln -s /opt/hadoop-3.3.6 /opt/hadoop
	
# Create HDFS directories and set permissions
RUN mkdir -p /opt/hadoop-3.3.6/logs && \
	mkdir -p /opt/hadoop-3.3.6/data/namenode && \
	mkdir -p /opt/hadoop-3.3.6/data/datanode && \
	chown -R spark:spark /opt/hadoop-3.3.6
	
# Set environment variables
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

# Add JAVA_HOME to hadoop-env.sh (replace existing line)
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" >> $HADOOP_CONF_DIR/hadoop-env.sh && \
    echo 'export HDFS_NAMENODE_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED"' >> $HADOOP_CONF_DIR/hadoop-env.sh && \
    echo 'export HDFS_DATANODE_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED"' >> $HADOOP_CONF_DIR/hadoop-env.sh && \
    echo 'export HDFS_SECONDARYNAMENODE_OPTS="--add-opens java.base/java.lang=ALL-UNNAMED"' >> $HADOOP_CONF_DIR/hadoop-env.sh

# Create HDFS directories and set permissions
RUN mkdir -p /opt/hadoop/data/namenode && \
	mkdir -p /opt/hadoop/data/datanode && \
	mkdir -p /opt/hadoop/logs && \
	chown -R spark:spark /opt/hadoop
	
# Install Python packages
RUN pip3 install --no-cache-dir \
	pyspark \
	jupyter \
	pandas \
	numpy

# Create home directory for spark user and configure SSH
RUN mkdir -p /home/spark && \
	chown -R spark:spark /home/spark && \
	mkdir -p /home/spark/.ssh && \
	ssh-keygen -t rsa -P '' -f /home/spark/.ssh/id_rsa && \
	cat /home/spark/.ssh/id_rsa.pub >> /home/spark/.ssh/authorized_keys && \
	chmod 700 /home/spark/.ssh && \
	chmod 600 /home/spark/.ssh/authorized_keys && \
	chown -R spark:spark /home/spark/.ssh

# Configure SSH server
RUN mkdir -p /run/sshd && \
	echo "spark ALL=(ALL) NOPASSWD: /usr/sbin/service ssh start" >> /etc/sudoers && \
	echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
	
# Configure Hadoop
RUN echo '<?xml version="1.0"?>\n\
<configuration>\n\
  <property>\n\
    <name>fs.defaultFS</name>\n\
    <value>hdfs://spark-master:9000</value>\n\
  </property>\n\
  <property>\n\
    <name>dfs.webhdfs.enabled</name>\n\
    <value>true</value>\n\
  </property>\n\
</configuration>' > $HADOOP_CONF_DIR/core-site.xml && \
echo '<?xml version="1.0"?>\n\
<configuration>\n\
  <property>\n\
    <name>dfs.replication</name>\n\
    <value>1</value>\n\
  </property>\n\
  <property>\n\
    <name>dfs.namenode.name.dir</name>\n\
    <value>file:///opt/hadoop-3.3.6/data/namenode</value>\n\
  </property>\n\
  <property>\n\
    <name>dfs.datanode.data.dir</name>\n\
    <value>file:///opt/hadoop-3.3.6/data/datanode</value>\n\
  </property>\n\
</configuration>' > $HADOOP_CONF_DIR/hdfs-site.xml

USER spark
WORKDIR /opt/spark
