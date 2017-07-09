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

### install gosu 1.9 for easy step-down from root
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

WORKDIR /opt

RUN useradd -ms /bin/bash elasticsearch \
        && yum install -y net-tools wget which openssl



RUN rpm --import http://packages.elastic.co/GPG-KEY-elasticsearch
RUN echo '[elasticsearch-5.x] \
    name=Elasticsearch repository for 5.x packages \
    baseurl=http://packages.elastic.co/elasticsearch/2.x/centos \
    gpgcheck=1 \
    gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch \
    enabled=1' | tee /etc/yum.repos.d/elasticsearch.repo \
    && yum -y install elasticsearch

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
ENTRYPOINT ["/run/entrypoint.sh"]

CMD ["/opt/elasticsearch/bin/elasticsearch"]
