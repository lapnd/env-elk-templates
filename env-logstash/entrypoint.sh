#!/bin/sh

sed -i -e "s/__ELASTICSEARCH_HOST__/$ELASTIC_CLIENT_PORT_9200_TCP_ADDR/g" -e "s/__ELASTICSEARCH_PORT__/$ELASTIC_CLIENT_PORT_9200_TCP_PORT/g" "$LOGSTASH_CONFIG"

# Drop root privileges if we are running logstash
if [ "${3:0:8}" = 'logstash' ]; then
      exec /usr/bin/tini --  gosu logstash_user "$@"
fi

# As argument is not related to logstash, then assume that user wants to run his own process, for example a `bash` shell to explore this image
exec /usr/bin/tini -- "$@"
