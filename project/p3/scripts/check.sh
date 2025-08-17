#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
ns_argocd="argocd"
ns_app="dev"

CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${CYAN}== Versions ==${NC}"
command -v docker >/dev/null && docker --version || echo "${RED}docker : non trouvé${NC}"
command -v kubectl >/dev/null && kubectl version --client --output=yaml | grep gitVersion || echo "${RED}kubectl : non trouvé${NC}"
command -v k3d >/dev/null && k3d version | head -1 || echo "${RED}k3d : non trouvé${NC}"

echo -e "\n${CYAN}== Cluster ==${NC}"
kubectl cluster-info || true
kubectl get ns || true

echo -e "\n${CYAN}== Pods ArgoCD ==${NC}"
kubectl get pods -n "${ns_argocd}" || true

echo -e "\n${CYAN}== Pods Application (dev) ==${NC}"
kubectl get pods -n "${ns_app}" || true

echo -e "\n${CYAN}== Application Argo ==${NC}"
kubectl -n "${ns_argocd}" get applications.argoproj.io || true

echo -e "\n${CYAN}== Check Application ==${NC}"
set +e
kubectl -n "${ns_app}" port-forward svc/playground-svc 8888:8888 >/tmp/pf.log 2>&1 &
PF=$!
sleep 2
curl -s http://localhost:8888/ || echo "${RED}curl : echec de la connexion${NC}"
kill "$PF" 2>/dev/null
set -e
echo ""