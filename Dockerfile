FROM ubuntu:16.04

ENV CONFD_VERSION="0.12.0-alpha3" \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download" \
    SSH_PORT="22" \
    GOVERSION="1.7.4" \
    GOPATH="/go" \
    GOROOT="/goroot" \
    TUNNEL_USER="tunnel"

RUN apt-get update \
    && apt-get install -y openssh-server wget \
    && wget --retry-connrefused -t 5 ${CONFD_URL}/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -O /bin/confd \
    && chmod +x /bin/confd \
    && apt-get purge -y --auto-remove wget \
    && apt-get clean

RUN apt-get update \
    && apt-get -y install git curl \
    && apt-get install -y ca-certificates \
    && curl https://storage.googleapis.com/golang/go${GOVERSION}.linux-amd64.tar.gz | tar xzf - \
    && mv /go ${GOROOT} \
    && ${GOROOT}/bin/go get github.com/camptocamp/github_pki \
    && apt-get purge -y --auto-remove git curl \
    && rm -rf go${GOVERSION}.linux-amd64.tar.gz ${GOROOT} \
    && apt-get clean

RUN mkdir /var/run/sshd

ADD *.toml /etc/confd/conf.d/
ADD *.tmpl /etc/confd/templates/
ADD entrypoint.sh /

# Don't allow login
RUN useradd -s /usr/sbin/nologin -m ${TUNNEL_USER} \
    && usermod -p '*' ${TUNNEL_USER} \
    && mkdir /home/${TUNNEL_USER}/.ssh \
    && chmod 0700 /home/${TUNNEL_USER}/.ssh

ADD wrapper.sh /

VOLUME [ "/etc/ssh" ]

ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/true
