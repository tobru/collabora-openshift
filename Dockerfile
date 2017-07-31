FROM centos:centos7

RUN yum -y --setopt=tsflags=nodocs install wget openssl && \
    wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && \
    rpm --import repomd.xml.key && \
    yum-config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7 && \
    yum -y --setopt=tsflags=nodocs --nogpgcheck install loolwsd CODE-brand && \
    mkdir /home/lool && chown -R lool:lool /home/lool && \
    chown -R lool:lool /etc/loolwsd && \
    wget -O /usr/local/sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/sbin/dumb-init

ADD entrypoint.sh /
ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["loolwsd"]
