#!/bin/sh

# Drop root privileges if we are running logstash
if [ "${3:0:8}" = 'logstash' ]; then
      exec gosu logstash_user "$@"
fi

# As argument is not related to logstash, then assume that user wants to run his own process, for example a `bash` shell to explore this image
exec "$@"
