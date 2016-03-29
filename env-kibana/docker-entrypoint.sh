#!/bin/bash

# Fail hard and fast
set -eo pipefail

# Elastic ENV variables
export ELASTIC_NAME=${ELASTIC_NAME:-elastic}

# Commented cause using Docker Global values
#export ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST:-localhost}
#export ELASTICSEARCH_PORT=${ELASTICSEARCH_PORT:-9200}

# Create workiing folders and fix permissions
mkdir -p /data/$ELASTIC_NAME; chown -fR elastic:elastic /data/$ELASTIC_NAME

# add elastic host and port to config
sed -i -e "s/__ELASTICSEARCH_HOST__/$ELASTIC_CLIENT_PORT_9200_TCP_ADDR/g" -e "s/__ELASTICSEARCH_PORT__/$ELASTIC_CLIENT_PORT_9200_TCP_PORT/g" "$KIBANA_CONFIG"

# Drop root privileges if we are running elasticsearch
if [ "${3:0:4}" = 'node' ]; then
	exec gosu elastic "$@"
fi

# As argument is not related to elasticsearch, then assume that user wants to run his own process, for example a `bash` shell to explore this image
exec "$@"
