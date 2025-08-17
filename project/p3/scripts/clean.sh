#!/usr/bin/env bash
GREEN="\033[0;32m"
NC="\033[0m"

set -euo pipefail
kubectl -n argocd delete application iot-playground --ignore-not-found
kubectl -n dev delete all --all || true
echo -e "${GREEN}Toutes les applications et ressources dans l'espace de noms 'dev' ont ete supprimees${NC}"
