#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
if [[ -f "${ENV_FILE}" ]]; then
  set -a
  . "${ENV_FILE}"
  set +a
fi

ns="argocd"
svc="argocd-server"

kubectl -n "${ns}" port-forward "svc/${svc}" 8080:443 >/tmp/argocd-portfw.log 2>&1 &
PF_PID=$!
cleanup() { kill "$PF_PID" 2>/dev/null || true; }
trap cleanup EXIT

for i in {1..30}; do
  if curl -skI https://localhost:8080 >/dev/null 2>&1; then break; fi
  sleep 1
done

echo "Lien: https://localhost:8080"
echo "Username: admin"

INIT_PASS="$(kubectl -n "${ns}" get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d || true)"
if [[ -n "${INIT_PASS}" ]]; then
  echo "Password initial: ${INIT_PASS}"
else
  echo "Password initial non disponible"
  echo "  kubectl -n ${ns} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
fi

wait "$PF_PID"
