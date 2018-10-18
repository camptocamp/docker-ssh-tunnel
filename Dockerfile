FROM golang:1.11 as builder

RUN go get -d -v github.com/camptocamp/github_pki && go build -v -o /github_pki github.com/camptocamp/github_pki

FROM ubuntu:16.04

ENV CONFD_VERSION="0.16.0" \
    CONFD_SHA256="255d2559f3824dd64df059bdc533fd6b697c070db603c76aaf8d1d5e6b0cc334" \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download" \
    SSH_PORT="22" \
    TUNNEL_USER="tunnel"

COPY --from=builder /github_pki /usr/local/bin/github_pki

RUN apt-get update \
    && apt-get install -y openssh-server wget \
    && wget --retry-connrefused -t 5 ${CONFD_URL}/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -O /usr/local/bin/confd \
    && echo "${CONFD_SHA256} /usr/local/bin/confd" | sha256sum -c - \
    && chmod +x /usr/local/bin/confd \
    && apt-get purge -y --auto-remove wget \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

RUN mkdir /var/run/sshd

ADD *.toml /etc/confd/conf.d/
ADD *.tmpl /etc/confd/templates/
ADD entrypoint.sh /

# Don't allow login
RUN useradd -s /usr/sbin/nologin -m ${TUNNEL_USER} \
    && usermod -p '*' ${TUNNEL_USER} \
    && mkdir /home/${TUNNEL_USER}/.ssh \
    && chmod 0700 /home/${TUNNEL_USER}/.ssh


VOLUME [ "/etc/ssh" ]

ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/true
