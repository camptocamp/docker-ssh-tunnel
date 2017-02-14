#!/bin/sh
set -e

if test -n "$AUTHORIZED_KEYS"; then
  echo "$AUTHORIZED_KEYS" > /root/.ssh/authorized_keys
fi

nohup /usr/sbin/sshd -E /ssh.log &

# Run confd to build configuration files
/bin/confd --backend rancher --prefix /latest --log-level debug --interval 60
