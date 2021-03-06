#!/bin/bash
set -e

export HOME=/home/lool

# TODO replace this with a cleaner implementation
if test "${DONT_GEN_SSL_CERT-set}" == set; then

  if [ ! -f /home/lool/ssl/certs/ca/root.key.pem ]; then
    # Generate new SSL certificate instead of using the default
    mkdir -p /home/lool/ssl/
    cd /home/lool/ssl/
    mkdir -p certs/ca

    openssl genrsa -out certs/ca/root.key.pem 2048
    openssl req -x509 -new -nodes -key certs/ca/root.key.pem -days 9131 -out certs/ca/root.crt.pem -subj "/C=DE/ST=BW/L=Stuttgart/O=Dummy Authority/CN=Dummy Authority"

    mkdir -p certs/{servers,tmp}
    mkdir -p "certs/servers/localhost"

    openssl genrsa -out "certs/servers/localhost/privkey.pem" 2048 -key "certs/servers/localhost/privkey.pem"

    if test "${cert_domain-set}" == set; then
      openssl req -key "certs/servers/localhost/privkey.pem" -new -sha256 -out "certs/tmp/localhost.csr.pem" -subj "/C=DE/ST=BW/L=Stuttgart/O=Dummy Authority/CN=localhost"
    else
      openssl req -key "certs/servers/localhost/privkey.pem" -new -sha256 -out "certs/tmp/localhost.csr.pem" -subj "/C=DE/ST=BW/L=Stuttgart/O=Dummy Authority/CN=${cert_domain}"
    fi

    openssl x509 -req -in certs/tmp/localhost.csr.pem -CA certs/ca/root.crt.pem -CAkey certs/ca/root.key.pem -CAcreateserial -out certs/servers/localhost/cert.pem -days 9131
    mv certs/servers/localhost/privkey.pem /etc/loolwsd/key.pem
    mv certs/servers/localhost/cert.pem /etc/loolwsd/cert.pem
    mv certs/ca/root.crt.pem /etc/loolwsd/ca-chain.cert.pem
  fi

fi

# Run loolwsd when asked to do so
if [ "$1" = 'loolwsd' ]; then
  echo "===> Starting Collabora Online"
  exec /usr/bin/loolwsd \
       --version \
       --o:sys_template_path=/opt/lool/systemplate \
       --o:lo_template_path=/opt/collaboraoffice5.3 \
       --o:child_root_path=/opt/lool/child-roots \
       --o:file_server_root_path=/usr/share/loolwsd
fi

# Run CMD
exec "$@"
