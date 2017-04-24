#!/bin/bash

export HOME=/home/vcap/app
[ -d ~/.profile.d ] && for f in ~/.profile.d/*; do source $f; done
set -euo pipefail

trap "on_exit" EXIT

SSH_PRIVATE_KEY=$(echo ${VCAP_SERVICES} | jq -r '.["user-provided"][]|select(.name=="redis")|.credentials.ssh_private_key')
SSH_CONNECTION_STRING=$(echo ${VCAP_SERVICES} | jq -r '.["user-provided"][]|select(.name=="redis")|.credentials.ssh_connection_string')

mkdir -p ~/.ssh
echo "${SSH_PRIVATE_KEY}" | base64 -d > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

$SSH_CONNECTION_STRING -f -o StrictHostKeyChecking=no -i /home/vcap/app/.ssh/id_rsa || kill 0

rackup -p $PORT
