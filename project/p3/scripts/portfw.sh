#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

GREEN="\033[0;32m"
NC="\033[0m"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  . "${ENV_FILE}"
  set +a
fi

ns="argocd"
svc="argocd-server"

kubectl -n "${ns}" port-forward --address 0.0.0.0 "svc/${svc}" 8080:443 >/tmp/argocd-portfw.log 2>&1 &
PF_PID=$!
cleanup() { kill "$PF_PID" 2>/dev/null || true; }
trap cleanup EXIT

mapfile -t ipv4s < <(ip -4 addr show scope global | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | sort -u)
printf "\n${GREEN}[Liens disponibles]${NC}\n"
for ip in "${ipv4s[@]}"; do
	echo "  https://${ip}:8080"
done

printf "\n${GREEN}[Identifiants]${NC}\n"
echo "  Username: admin"

INIT_PASS="$(kubectl -n "${ns}" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || true)"
if [[ -n "${INIT_PASS}" ]]; then
  echo "  Password: ${INIT_PASS}"
else
  echo "  Password initial non disponible"
  echo "  kubectl -n ${ns} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
fi
echo ""

wait "$PF_PID"
