#!/bin/bash
RET=1

while [[ RET -ne 0 ]]; do
    echo "Stalling for Elasticsearch..."
    curl -XGET http://elasticsearch:9200/" >/dev/null 2>&1
    RET=$?
    sleep 30
done
