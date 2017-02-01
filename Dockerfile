FROM ubuntu:16.04

ENV CONFD_VERSION="0.12.0-alpha3" \
    CONFD_URL="https://github.com/kelseyhightower/confd/releases/download" \
    SSH_PORT="22"

RUN apt-get update \
    && apt-get install -y openssh-server wget \
    && wget --retry-connrefused -t 5 ${CONFD_URL}/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 -O /bin/confd \
    && chmod +x /bin/confd \
    && apt-get purge -y --auto-remove wget \
    && apt-get clean

RUN mkdir /var/run/sshd

ADD sshd.toml /etc/confd/conf.d/
ADD sshd.tmpl /etc/confd/templates/
ADD entrypoint.sh /

RUN mkdir /root/.ssh \
    && chmod 0600 /root/.ssh

# Don't allow login
RUN chsh -s /usr/sbin/nologin root

VOLUME [ "/etc/ssh", "/root/.ssh" ]

ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/true
