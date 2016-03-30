FROM alpine:edge
MAINTAINER sporokh@softserveinc.com

# Set environment variables
ENV NODE_OPTIONS=${NODE_OPTIONS}

ENV KIBANA_VERSION=${KIBANA_VERSION:-4.4.2}
ENV PKG_NAME=${PKG_NAME:-kibana}
ENV PKG_PLATFORM=${PKG_PLATFORM:-linux-x64}
ENV KIBANA_PKG $PKG_NAME-$KIBANA_VERSION-$PKG_PLATFORM
ENV KIBANA_BASE_PATH=${KIBANA_BASE_PATH:-/opt}
ENV KIBANA_PATH=$KIBANA_BASE_PATH/$PKG_NAME
ENV KIBANA_CONFIG=${KIBANA_CONFIG:-$KIBANA_BASE_PATH/$PKG_NAME-$KIBANA_VERSION-$PKG_PLATFORM/config/kibana.yml}
ENV KIBANA_URL=${KIBANA_URL:-https://download.elastic.co/$PKG_NAME/$PKG_NAME/$KIBANA_PKG.tar.gz}

ENV ELASTIC_NAME=${ELASTIC_NAME:-elastic}
ENV SOFTWARE_DOWNLOAD_TIMEOUT=${SOFTWARE_DOWNLOAD_TIMEOUT:-300}

# Set nodejs variables
ENV GOSU_VERSION=${GOSU_VERSION:-1.7}

# Download Kibana and nodejs
RUN apk add --update nodejs bash curl && \
        curl -ksL -o /bin/gosu https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 && \
	chmod +x /bin/gosu && \
	mkdir -p /$KIBANA_BASE_PATH && \
	curl -ksL $KIBANA_URL | tar -zxvf - -C $KIBANA_BASE_PATH && \
	ln -s /$KIBANA_BASE_PATH/$KIBANA_PKG /$KIBANA_BASE_PATH/$PKG_NAME && \
	rm -Rf /$KIBANA_BASE_PATH/$KIBANA_PKG/node /$KIBANA_BASE_PATH/$KIBANA_PKG/bin && \
	adduser -D -H -h /data/$ELASTIC_NAME -s /bin/bash elastic && \
	chown -Rf elastic $KIBANA_BASE_PATH/kibana* && \
	rm -rf /tmp/* /var/cache/apk/*

COPY docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

COPY kibana.yml $KIBANA_CONFIG

VOLUME ["/data/$ELASTIC_NAME"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5601

CMD node ${NODE_OPTIONS} ${KIBANA_PATH}/src/cli
