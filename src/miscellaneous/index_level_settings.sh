#!/bin/bash

curl -XPUT -k -u "elasticsearch:to4get" 'http://elasticsearch:9200/_all/_settings?preserve_existing=true' -d '{"index.auto_expand_replicas" : "0-all"}'
