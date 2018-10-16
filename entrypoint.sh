#!/bin/sh
set -e

if test -n "$AUTHORIZED_KEYS"; then
  echo "$AUTHORIZED_KEYS" > /home/tunnel/.ssh/authorized_keys
fi
chown -R "$TUNNEL_USER". "/home/$TUNNEL_USER"

nohup /usr/sbin/sshd -E /ssh.log &

# Run confd to build configuration files
/bin/confd --backend rancher --prefix /latest --interval 600
