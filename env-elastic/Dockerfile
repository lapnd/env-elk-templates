FROM alpine:edge
MAINTAINER mrys@softserveinc.com

# k8s
ENV container docker

# Set environment variables
ENV ELASTIC_VERSION=${ELASTIC_VERSION:-2.1.1}
ENV ELASTIC_URL=${ELASTIC_URL:-https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-$ELASTIC_VERSION.tar.gz}
ENV ELASTIC_BASE_PATH=${ELASTIC_BASE_PATH:-/opt}
ENV ELASTIC_PATH $ELASTIC_BASE_PATH/elastic
ENV PATH $ELASTIC_PATH/bin:$PATH
ENV SOFTWARE_DOWNLOAD_TIMEOUT=${SOFTWARE_DOWNLOAD_TIMEOUT:-300}
ENV GOSU_VERSION=${GOSU_VERSION:-1.7}

ENV ELASTIC_NAME=${ELASTIC_NAME:-elastic}

# java envs
ENV SOFTWARE_DOWNLOAD_RETRIES=${SOFTWARE_DOWNLOAD_RETRIES:-10}
ENV JAVA_HOME_BASE=${JAVA_HOME_BASE:-/opt}
ENV JAVA_HOME $JAVA_HOME_BASE/jre
ENV JRE_URL=${JRE_URL:-http://download.oracle.com/otn-pub/java/jdk/8u66-b17/server-jre-8u66-linux-x64.tar.gz}

ENV GLIBC_URL https://github.com/7insyde/external-libraries/releases/download/1.0/glibc-2.21-r2.apk
ENV GLIBC_BIN_URL https://github.com/7insyde/external-libraries/releases/download/1.0/glibc-bin-2.21-r2.apk
ENV PATH $JAVA_HOME/bin:$PATH


# Install Java and Elastic
RUN apk --update add curl && \
	curl -kL -o /tmp/glibc-2.21-r2.apk $GLIBC_URL && \
	curl -kL -o /tmp/glibc-bin-2.21-r2.apk $GLIBC_BIN_URL && \
	cd /tmp && apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
	/usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
	mkdir $JAVA_HOME_BASE && cd $JAVA_HOME_BASE && (curl --connect-timeout $SOFTWARE_DOWNLOAD_TIMEOUT --retry $SOFTWARE_DOWNLOAD_RETRIES -Lskj -b "oraclelicense=accept-securebackup-cookie" $JRE_URL | gunzip -c - | tar xf - ) && \
	chown -Rf root:root $JAVA_HOME_BASE/jdk* && \
	ln -s $JAVA_HOME_BASE/jdk* $JAVA_HOME && \
	ln -s $JAVA_HOME/bin/java /usr/bin/java && \
	rm -rf $JAVA_HOME/*src.zip && \
	rm -rf $JAVA_HOME/lib/missioncontrol \
		$JAVA_HOME/lib/visualvm \
		$JAVA_HOME/lib/*javafx* \
		$JAVA_HOME/jre/lib/plugin.jar \
		$JAVA_HOME/jre/lib/ext/jfxrt.jar \
		$JAVA_HOME/jre/bin/javaws \
		$JAVA_HOME/jre/lib/javaws.jar \
		$JAVA_HOME/jre/lib/desktop \
		$JAVA_HOME/jre/plugin \
		$JAVA_HOME/jre/lib/deploy* \
		$JAVA_HOME/jre/lib/*javafx* \
		$JAVA_HOME/jre/lib/*jfx* \
		$JAVA_HOME/jre/lib/amd64/libdecora_sse.so \
		$JAVA_HOME/jre/lib/amd64/libprism_*.so \
		$JAVA_HOME/jre/lib/amd64/libfxplugins.so \
		$JAVA_HOME/jre/lib/amd64/libglass.so \
		$JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so \
		$JAVA_HOME/jre/lib/amd64/libjavafx*.so \
		$JAVA_HOME/jre/lib/amd64/libjfx*.so && \
	rm -rf $JAVA_HOME/jre/bin/jjs \
		$JAVA_HOME/jre/bin/keytool \
		$JAVA_HOME/jre/bin/orbd \
		$JAVA_HOME/jre/bin/pack200 \
		$JAVA_HOME/jre/bin/policytool \
		$JAVA_HOME/jre/bin/rmid \
		$JAVA_HOME/jre/bin/rmiregistry \
		$JAVA_HOME/jre/bin/servertool \
		$JAVA_HOME/jre/bin/tnameserv \
		$JAVA_HOME/jre/bin/unpack200 \
		$JAVA_HOME/jre/lib/ext/nashorn.jar \
		$JAVA_HOME/jre/lib/jfr.jar \
		$JAVA_HOME/jre/lib/jfr \
		$JAVA_HOME/jre/lib/oblique-fonts && \
	apk del curl libssh2 ca-certificates && \

    apk update && apk upgrade && \
    apk --update add openssl bash && \
    wget -T $SOFTWARE_DOWNLOAD_TIMEOUT -q -O /bin/gosu https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 && \
    chmod +x /bin/gosu && \
    mkdir -p $ELASTIC_BASE_PATH && \
    wget -T $SOFTWARE_DOWNLOAD_TIMEOUT -q -O- $ELASTIC_URL | tar -zxvf - -C $ELASTIC_BASE_PATH && \
    ln -sf $ELASTIC_BASE_PATH/elasticsearch-$ELASTIC_VERSION $ELASTIC_PATH && \
    rm -rf $(find $ELASTIC_PATH | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))") && \
    adduser -D -H -h /data/$ELASTIC_NAME -s /bin/bash elastic && \
    chown -Rf elastic $ELASTIC_BASE_PATH/elastic* && \
    rm -rf /tmp/* /var/cache/apk/*

RUN cd $ELASTIC_PATH && \
	./bin/plugin install royrusso/elasticsearch-HQ

COPY docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

COPY config $ELASTIC_PATH/config

VOLUME ["/data/$ELASTIC_NAME"]

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch"]
