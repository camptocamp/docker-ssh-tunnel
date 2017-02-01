#!/bin/sh
set -e

nohup /usr/sbin/sshd &

# Run confd to build configuration files
/bin/confd --backend rancher --log-level debug
