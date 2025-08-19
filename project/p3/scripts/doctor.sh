#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

ok=true

for bin in docker k3d git curl; do
	if command -v "$bin" >/dev/null 2>&1; then
		if [ "$bin" = "curl" ]; then
			version=$("$bin" --version 2>/dev/null | head -1 | awk '{print $1, $2}')
		else
			version=$("$bin" --version 2>/dev/null | head -1)
		fi
		echo -e "  ${GREEN}✔${RESET}   $bin OK ($version)"
	else
		echo -e "  ${RED}✘${RESET}   $bin KO"
		ok=false
	fi
done


if command -v kubectl >/dev/null 2>&1; then
	if command -v jq >/dev/null 2>&1; then
		kubectl_version=$(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion // "unknown"')
		echo -e "  ${GREEN}✔${RESET}   kubectl OK (client version: $kubectl_version)"
	else
		kubectl_version=$(kubectl version --client 2>/dev/null | grep -E 'GitVersion|Version' | head -1 | awk -F: '{print $2}' | xargs)
		echo -e "  ${GREEN}✔${RESET}   kubectl OK (client version: $kubectl_version)"
	fi
else
	echo -e "  ${RED}✘${RESET}   kubectl KO"
	ok=false
fi

if $ok; then
	echo -e "${GREEN}Tous les outils requis sont correctement installes${RESET}"
else
	echo -e "${YELLOW}Certains outils sont manquants. Veuillez les installer avant de lancer 'make up'.${RESET}"
fi
