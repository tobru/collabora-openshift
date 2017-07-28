FROM centos:centos7

RUN yum -y --setopt=tsflags=nodocs install wget openssl && \
    wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && \
    rpm --import repomd.xml.key && \
    yum-config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7 && \
    yum -y --setopt=tsflags=nodocs --nogpgcheck install loolwsd CODE-brand && \
    mkdir /home/lool && chown -R lool:lool /home/lool

RUN chown -R lool:lool /etc/loolwsd

ADD entrypoint.sh /
ENTRYPOINT /entrypoint.sh

CMD ["/usr/bin/loolwsd", \
     "--version", \
     "--o:sys_template_path=/opt/lool/systemplate", \
     "--o:lo_template_path=/opt/collaboraoffice5.3", \
     "--o:child_root_path=/opt/lool/child-roots", \
     "--o:file_server_root_path=/usr/share/loolwsd"]
