#!/usr/bin/env bash
set -euo pipefail

SERVER_IP="${1:?missing server ip}"
WORKER_IP="${2:?missing worker ip}"
TOKEN="${3:?missing K3S token}"

# check IP server and worker (subject mandatory)
if [ "$SERVER_IP" != "192.168.56.110" ] || [ "$WORKER_IP" != "192.168.56.111" ]; then
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] Erreur : IP du serveur ou du worker incorrecte (SERVER_IP=$SERVER_IP, WORKER_IP=$WORKER_IP)."
	exit 1
fi

apt-get update -y && apt-get install -y curl netcat-openbsd net-tools

# wait for server
until nc -z "$SERVER_IP" 6443; do
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] En attente de $SERVER_IP:6443"; sleep 2
done

# check if k3s is already installed
if command -v k3s >/dev/null 2>&1; then
	exit 0
fi

curl -sfL https://get.k3s.io | \
	K3S_URL="https://${SERVER_IP}:6443" \
	K3S_TOKEN="${TOKEN}" \
	sh -s - --node-ip "${WORKER_IP}"
