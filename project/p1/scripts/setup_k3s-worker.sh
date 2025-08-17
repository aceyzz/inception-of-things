#!/usr/bin/env bash
set -euo pipefail

SERVER_IP="${1:?missing server ip}"
TOKEN="${2:?missing K3S token}"

if command -v k3s >/dev/null 2>&1; then
	exit 0
fi

curl -sfL https://get.k3s.io | K3S_URL="https://${SERVER_IP}:6443" K3S_TOKEN="${TOKEN}" sh -
