# from frolvlad/alpine-glibc:alpine-3.14
FROM frolvlad/alpine-glibc:alpine-3.14

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG ALPINE_VER=v3.14
ARG USER=app
ARG GROUP=app
ARG UID=8888
ARG GID=8888
ARG APP_HOME=/data/app
ARG GOSU_URL=https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64

# copy script
COPY docker-entrypoint.sh /

# install repositories and packages : busybox-suid curl bash bash-completion openssh wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu
RUN echo -e "https://mirrors.huaweicloud.com/alpine/${ALPINE_VER}/main\nhttps://mirrors.huaweicloud.com/alpine/${ALPINE_VER}/community" > /etc/apk/repositories && \
    apk update && apk add busybox-suid curl bash bash-completion openssh wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu && \
    \rm -rf /var/cache/apk/* && \
    ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key  -N '' && \
    ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config && \
    sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config && \
    echo "Asia/Shanghai" > /etc/timezone && \ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    touch /home/.bashrc && \
    echo "export HISTTIMEFORMAT=\"%d/%m/%y %T \"" >> /home/.bashrc && \
    echo "export PS1='[\u@\h \W]\$ '" >> /home/.bashrc && \
    echo "alias ll='ls -al'" >> /home/.bashrc && \
    echo "alias ls='ls --color=auto'" >> /home/.bashrc && \
    chmod +x /home/.bashrc && \
    mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh && \
    sed -i 's/root:x:0:0:root:\/root:\/bin\/ash/root:x:0:0:root:\/root:\/bin\/bash/g' /etc/passwd && echo -e 'admin\nadmin' | passwd root && \
    \cp /home/.bashrc /root && \
    chown -R root:root /root/.bashrc && \
    mkdir -p ${APP_HOME} && \
    addgroup -S -g ${GID} ${GROUP} && \
    adduser -S -G ${GROUP} -h ${APP_HOME} -u ${UID} -s /bin/bash ${USER} && echo -e '123456\n123456' | passwd ${USER} && \
    \cp /home/.bashrc ${APP_HOME} && \
    chown -R ${UID}:${GID} ${APP_HOME}/.bashrc && \
    wget -c -O /usr/local/bin/gosu --no-cookies --no-check-certificate "${GOSU_URL}" && chmod +x /usr/local/bin/gosu && \
    chown -R ${UID}:${GID} /data && \
    chown -R ${UID}:${GID} /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# set environment
ENV LANG C.UTF-8
ENV TZ "Asia/Shanghai"
ENV TERM xterm

# set work home
WORKDIR /data

# expose port 22
EXPOSE 22

# stop signal
STOPSIGNAL SIGTERM

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]
