#!/bin/sh
set -e

nohup /usr/sbin/sshd -E /ssh.log &

# Run confd to build configuration files
/bin/confd --backend rancher --prefix /latest --log-level debug --interval 60
