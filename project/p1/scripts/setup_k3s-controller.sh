#!/usr/bin/env bash
set -euo pipefail

TOKEN="${1:?missing K3S token}"
if command -v k3s >/dev/null 2>&1; then
	exit 0
fi

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --write-kubeconfig-mode 644 --token ${TOKEN}" sh -
