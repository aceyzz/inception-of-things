#!/usr/bin/env bash
set -euo pipefail

SERVER_IP="${1:?missing server ip}"
TOKEN="${2:?missing K3S token}"

apt-get update -y && apt-get install -y curl netcat-openbsd net-tools

if command -v k3s >/dev/null 2>&1; then
	exit 0
fi

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="\
	--disable traefik \
	--node-ip ${SERVER_IP} \
	--advertise-address ${SERVER_IP} \
	--write-kubeconfig-mode 644 \
	--token ${TOKEN} \
" sh -
