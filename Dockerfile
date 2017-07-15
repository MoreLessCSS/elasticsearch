#Docker default CentosJava image
FROM nimmis/java-centos

MAINTAINER me <me@me.com>
LABEL Description="elasticsearch 5.4"

ENV ES_VERSION=5.4.0 \
CLUSTER_NAME="me" \
CLUSTER_NAME="meCustomer" \
    NODE_NAME="elkmaster1" \
    HTTP_PORT_ES=9200 \
    NETWORK_HOST=0.0.0.0 \
    MINIMUM_MASTER_NODES=1 \
    MAXIMUM_LOCAL_STORAGE_NODES=1 \
    NODE_ATTR_RACK=centOS7 \
    ELASTIC_PWD="getme" \
    GOSU_VERSION=1.9 \
    JAVA_HOME="/usr/java/jre1.8.0_131/" \
    HEAP_SIZE="2g" \
    JVM_OPTS="-Xmx4g -Xms4g -XX:MaxPermSize=1024m" \
    ES_JAVA_OPTS="-Xmx2g -Xms2g"



WORKDIR /opt

RUN useradd -ms /bin/bash elasticsearch \
        && yum install -y net-tools wget which openssl

RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
    && tar -xzf elasticsearch-${ES_VERSION}.tar.gz \
    && rm elasticsearch-${ES_VERSION}.tar.gz \
    && ln -s elasticsearch-${ES_VERSION} elasticsearch

COPY /config/*.* /opt/elasticsearch/config/

RUN cd /opt/elasticsearch/

RUN echo y | /opt/elasticsearch/bin/elasticsearch-plugin install -s repository-s3
RUN echo y | /opt/elasticsearch/bin/elasticsearch-plugin install -s discovery-ec2

RUN LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) \
    && sed -i  "s/\\(^node\.name:\\).*/\\1 $LOCAL_IP/" ./elasticsearch/config/elasticsearch.yml


RUN chown -R elasticsearch:elasticsearch /opt/

ADD ./src/ /run/
RUN chmod +x -R /run/

EXPOSE 9200:9200
EXPOSE 9300:9300

USER elasticsearch


CMD ["/opt/elasticsearch/bin/elasticsearch"]
