ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG user=admin
ARG group=admin
ARG uid=1001
ARG gid=1001


ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.utf8
COPY canal/target/canal.deployer-*.tar.gz /tmp
RUN set -eux; \
    apt-get clean && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -yq \
    locales \
    ca-certificates \
    curl \
    openssh-client \
    psmisc \
    procps \
    iproute2 \
    tree \
    libfreetype6-dev \
    fontconfig \
    unzip \
    less \
    xz-utils \
    p7zip-full \
    zip \
    jq \
    && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
    mkdir -p /home/${user}/canal-server && \
    tar -xzvf /tmp/canal.deployer-*.tar.gz -C /home/${user}/canal-server && \
    rm -f /tmp/canal.deployer-*.tar.gz && \
    chown -R ${uid}:${gid} /home/${user} && \
    rm -rf /var/lib/apt/lists/*;

    EXPOSE 11110 11111 11112 9100

    WORKDIR /home/${user}