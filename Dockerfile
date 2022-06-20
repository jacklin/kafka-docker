FROM docker.io/bitnami/minideb:bullseye
LABEL maintainer "Bitnami <containers@bitnami.com>"
LABEL modifier "Sniper <jacklin@shouyiren.net>"

ENV HOME="/" \
    OS_ARCH="amd64" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux" \
    MY_ENABLE_POINT_TO_UNDERLINE=0 \
    MY_POD_IP="" \
    MY_POD_NAME="" \
    MY_CLUSTER_IN_DOMAIN_NAME=".explame.com"

ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"

COPY prebuildfs /

RUN chmod 777 /usr/sbin/install_packages
# Install required system packages and dependencies
RUN install_packages acl ca-certificates curl gzip libc6 procps tar zlib1g net-tools iputils-ping procps telnet
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "java" "11.0.15-150" --checksum fe6b65886a6b1f545508e272efbf422054ee030c867f94ebec2f93c5518252de
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "gosu" "1.14.0-150" --checksum da4a2f759ccc57c100d795b71ab297f48b31c4dd7578d773d963bbd49c42bd7b
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "wait-for-port" "1.0.3-150" --checksum 1013e2ebbe58e5dc8f3c79fc952f020fc5306ba48463803cacfbed7779173924
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "render-template" "1.0.3-150" --checksum 8b992a5ee513c5eaca52b19232b21a93588ddf4c4850be4d47c6f19b11d1d90a
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "kafka" "3.2.0-150" --checksum 7587d8d9ecf7d70b4601d512ef92d71c5a2d158f4cd5c9d4efebc2c3dccf1375
RUN apt-get update && apt-get upgrade -y && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives
RUN chmod 777 -R /opt/bitnami
RUN ln -s /opt/bitnami/scripts/kafka/entrypoint.sh /entrypoint.sh
RUN ln -s /opt/bitnami/scripts/kafka/run.sh /run.sh

COPY rootfs /
RUN chmod 777 -R /opt/bitnami
RUN /opt/bitnami/scripts/java/postunpack.sh
RUN /opt/bitnami/scripts/kafka/postunpack.sh
ENV APP_VERSION="3.2.0" \
    BITNAMI_APP_NAME="kafka" \
    JAVA_HOME="/opt/bitnami/java" \
    PATH="/opt/bitnami/java/bin:/opt/bitnami/common/bin:/opt/bitnami/kafka/bin:$PATH"

EXPOSE 9092

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/kafka/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/kafka/run.sh" ]
