#!/bin/bash

# Fail hard and fast
set -eo pipefail

# Check limits
mapmax=`cat /proc/sys/vm/max_map_count`
filemax=`cat /proc/sys/fs/file-max`
ulimit -a;
echo "fs.file_max: $filemax"
echo "vm.max_map_count: $mapmax"
fds=`ulimit -n`
if [ "$fds" -lt "64000" ] ; then
  echo "ES recommends 64k open files per process. you have "`ulimit -n`
  echo "the docker deamon should be run with increased file descriptors to increase those available in the container"
  echo " try \`ulimit -n 64000\`"
else
  echo "you have more than 64k allowed file descriptors. awesome."
fi

# Elastic ENV variables
export ELASTIC_NAME=${ELASTIC_NAME:-elastic}
export ELASTIC_NODE_MASTER=${ELASTIC_NODE_MASTER:-false}
export ELASTIC_NODE_DATA=${ELASTIC_NODE_DATA:-false}
export ELASTIC_HTTP_ENABLE=${ELASTIC_HTTP_ENABLE:-false}
export ELASTIC_MULTICAST=${ELASTIC_MULTICAST:-true}
export ELASTIC_CLIENT_NAME=${ELASTIC_CLIENT_NAME:-localhost}
export ELASTIC_CLIENT_PORT=${ELASTIC_CLIENT_PORT:-9200}

# Create workiing folders and fix permissions
mkdir -p /data/$ELASTIC_NAME/{data,logs}; chown -fR elastic:elastic /data/$ELASTIC_NAME

# Run topbeat-dashboard script to set all the metrics to human-readable format
if [ "${ELASTIC_HTTP_ENABLE}" = "true" ]; then
      sleep 30 && /tmp/dashboards/load.sh -url "$ELASTIC_CLIENT_NAME:$ELASTIC_CLIENT_PORT"&
fi

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
if [ "$1" = 'elasticsearch' ]; then
	exec gosu elastic "$@"
fi

# As argument is not related to elasticsearch, then assume that user wants to run his own process, for example a `bash` shell to explore this image
exec "$@"
