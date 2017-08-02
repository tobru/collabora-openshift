FROM centos:centos7

# Install Collabora and dumb-init
RUN yum -y --setopt=tsflags=nodocs install wget openssl epel-release gettext && \
    wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && \
    rpm --import repomd.xml.key && \
    yum-config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7 && \
    yum -y --setopt=tsflags=nodocs --nogpgcheck install loolwsd CODE-brand nss_wrapper && \
    # dumb-init
    wget -O /usr/local/sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 && \
    chmod +x /usr/local/sbin/dumb-init

# Setup directories and permissions
RUN mkdir /home/lool && \
    directories="/home/lool /etc/loolwsd /var/cache/loolwsd" && \
    chown -R lool:root $directories && \
    chmod -R g+rwX $directories

ADD entrypoint.sh /
COPY scripts/ /etc/loolwsd

USER 997

ENTRYPOINT ["/entrypoint.sh"]
CMD ["loolwsd"]
