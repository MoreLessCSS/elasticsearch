#Docker default CentosJava image
FROM nimmis/java-centos

MAINTAINER me <me@me.com>
LABEL Description="elasticsearch 5.4"

ENV ES_VERSION=5.4.0 \
    CLUSTER_NAME="ElasticCluster" \
    NODE_NAME="elkmaster1" \
    HTTP_PORT_ES=9200 \
    NETWORK_HOST=0.0.0.0 \
    MINIMUM_MASTER_NODES=1 \
    MAXIMUM_LOCAL_STORAGE_NODES=1 \
    NODE_ATTR_RACK=centOS7 \
    ELASTIC_PWD="getme" \
    GOSU_VERSION=1.9 \
    JAVA_HOME="/usr/java/jre1.8.0_131/" \
    HEAP_SIZE="4g"
    ES_JAVA_OPTS="-Xms4g -Xmx4g"


ENV JAVA_VERSION 8u31
ENV BUILD_VERSION b13

RUN useradd -ms /bin/bash elasticsearch \
        && yum install -y net-tools wget which openssl
### install gosu 1.9 for easy step-down from root
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

WORKDIR /opt

RUN rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
COPY /repos/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN yum -y install elasticsearch

COPY /config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
COPY /logging/logging.yml /usr/share/elasticsearch/config/logging.yml
COPY /etcconfig/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml


RUN echo y | /usr/share/elasticsearch/bin/elasticsearch-plugin install -s repository-s3
RUN echo y | /usr/share/elasticsearch/bin/elasticsearch-plugin install -s discovery-ec2

RUN LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4) \
    && sed -i  "s/\\(^node\.name:\\).*/\\1 $LOCAL_IP/" /usr/share/elasticsearch/config/elasticsearch.yml

RUN chown -R elasticsearch:elasticsearch /var/lib/elasticsearch
RUN chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/
RUN chown -R elasticsearch:elasticsearch /var/log/elasticsearch/
RUN chown -R elasticsearch:elasticsearch /etc/elasticsearch/


ADD ./src/ /run/
RUN chmod +x -R /run/

EXPOSE 9200:9200
EXPOSE 9300:9300

USER elasticsearch
ENTRYPOINT ["/run/entrypoint.sh"]

CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
