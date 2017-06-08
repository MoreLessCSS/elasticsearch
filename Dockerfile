#dockerfile for ES_54 based on Deutsche Bahn vendo-st-docker-prod-local.bahnhub.tech.rz.db.de/vendo-base-image-jre:1.8.0.131
FROM vendo-st-docker-prod-local.bahnhub.tech.rz.db.de/vendo-base-image-jre:1.8.0.131

MAINTAINER Robert Franjkovic <robert.franjkovic@deutschebahn.com>
LABEL Description="elasticsearch 5.4"

ENV ES_VERSION=5.4.0 \
    https_proxy=webproxy.aws.db.de:8080 \
    http_proxy=webproxy.aws.db.de:8080 \
    CLUSTER_NAME="vendo-elk" \
    NODE_NAME="elkmaster1" \
    HTTP_PORT_ES=9200 \
    NETWORK_HOST=0.0.0.0 \
    MINIMUM_MASTER_NODES=1 \
    MAXIMUM_LOCAL_STORAGE_NODES=1 \
    NODE_ATTR_RACK=centOS7 \
    ELASTIC_PWD="to4get" \
    GOSU_VERSION=1.9 \
    JAVA_HOME="/usr/java/jre1.8.0_131/" \
    HEAP_SIZE="1g"

### install gosu 1.9 for easy step-down from root
RUN set -x \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true

WORKDIR /opt

RUN useradd -ms /bin/bash elasticsearch \
        && yum install -y net-tools wget which openssl

RUN cd /opt

RUN curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz \
    && tar -xzf elasticsearch-${ES_VERSION}.tar.gz \
    && rm elasticsearch-${ES_VERSION}.tar.gz \
    && ln -s elasticsearch-${ES_VERSION} elasticsearch


COPY /config/*.* /opt/elasticsearch/config/

RUN chown -R elasticsearch:elasticsearch /opt/

ADD ./src/ /run/
RUN chmod +x -R /run/

USER elasticsearch

#ENTRYPOINT ["/run/entrypoint.sh"]

CMD ["/opt/elasticsearch/bin/elasticsearch"]
