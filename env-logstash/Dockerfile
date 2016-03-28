FROM alpine:edge
MAINTAINER Sergii Porokh <sporokh@softserveinc.com>

# java envs
ENV SOFTWARE_DOWNLOAD_TIMEOUT=${SOFTWARE_DOWNLOAD_TIMEOUT:-300}
ENV SOFTWARE_DOWNLOAD_RETRIES=${SOFTWARE_DOWNLOAD_RETRIES:-10}
ENV GOSU_VERSION=${GOSU_VERSION:-1.7}
ENV JAVA_HOME_BASE=${JAVA_HOME_BASE:-/opt}
ENV JAVA_HOME $JAVA_HOME_BASE/jre
ENV JRE_URL=${JRE_URL:-http://download.oracle.com/otn-pub/java/jdk/8u66-b17/server-jre-8u66-linux-x64.tar.gz}
ENV GLIBC_URL https://github.com/7insyde/external-libraries/releases/download/1.0/glibc-2.21-r2.apk
ENV GLIBC_BIN_URL https://github.com/7insyde/external-libraries/releases/download/1.0/glibc-bin-2.21-r2.apk

# Set environment variables
ENV LOGSTASH_NAME=${LOGSTASH_NAME:-logstash}
ENV LOGSTASH_VERSION=${LOGSTASH_VERSION:-2.2.2}
ENV LOGSTASH_URL=${LOGSTASH_URL:-https://download.elastic.co/$LOGSTASH_NAME/$LOGSTASH_NAME/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz}
ENV LOGSTASH_CONFIG=${LOGSTASH_CONFIG:-/opt/$LOGSTASH_NAME-$LOGSTASH_VERSION/etc/logstash.conf}
ENV JOURNAL_CONFIG=${JOURNAL_CONFIG:-/opt/$LOGSTASH_NAME-$LOGSTASH_VERSION/etc/journal.conf}
ENV LOGSTASH_BIN=${LOGSTASH_BIN:-/opt/$LOGSTASH_NAME-$LOGSTASH_VERSION/bin}
ENV PATH /opt/$LOGSTASH_NAME/bin:$JAVA_HOME/bin:$PATH

RUN apk --update add bash curl && \
    curl -kL --connect-timeout $SOFTWARE_DOWNLOAD_TIMEOUT --retry $SOFTWARE_DOWNLOAD_RETRIES -o /bin/gosu https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64 && \
    chmod +x /bin/gosu && \
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

    mkdir -p /opt \
    && curl -k -o /tmp/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz $LOGSTASH_URL \
    && tar xzf /tmp/$LOGSTASH_NAME-$LOGSTASH_VERSION.tar.gz -C /opt/ \
    && adduser -D -H -h /opt/$LOGSTASH_NAME -s /bin/bash logstash_user \
    && chown -Rf logstash_user /opt/$LOGSTASH_NAME* \
    && ln -s /opt/$LOGSTASH_NAME-$LOGSTASH_VERSION /opt/$LOGSTASH_NAME \
    && rm -rf /tmp/*.tar.gz /var/cache/apk/*

# Dedicate plugin install to another RUN layer
RUN /opt/logstash/bin/plugin install logstash-input-beats

COPY etc/logstash.conf $LOGSTASH_CONFIG

COPY docker-entrypoint.sh /
RUN chmod 0755 /docker-entrypoint.sh

EXPOSE 5044 5044/udp 8080

ENTRYPOINT ["/docker-entrypoint.sh"]

# CMD used without array syntax for interpolation of the $LOGSTASH_CONFIG
CMD logstash -f $LOGSTASH_CONFIG
