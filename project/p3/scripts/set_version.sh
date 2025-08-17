#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

RAW="${1:-}"
[[ -n "${RAW}" ]] || { echo -e "${RED}usage: $0 1|2${NC}"; exit 1; }
[[ "${RAW}" =~ ^[12]$ ]] || { echo -e "${RED}invalid version '${RAW}', must be 1 or 2${NC}"; exit 1; }
TAG="v${RAW}"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
if [[ -f "${ENV_FILE}" ]]; then
	set -a
	. "${ENV_FILE}"
	set +a
fi

REPO_BASE="github.com/aceyzz/cedmulle-42iot.git"
REPO_URL_NOAUTH="https://$REPO_BASE"

REPO_URL="${REPO_URL_NOAUTH}"
if [[ -n "${GIT_USER:-}" && -n "${GIT_TOKENPASS:-}" ]]; then
	case "${GIT_USER}${GIT_TOKENPASS}" in
	*:*|*@*)
		echo -e "${RED}caracteres invalides dans GIT_USER/GIT_TOKENPASS${NC}"; exit 1;;
	esac
	REPO_URL="https://${GIT_USER}:${GIT_TOKENPASS}@${REPO_BASE}"
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

git clone "${REPO_URL}" "${TMPDIR}/repo"
cd "${TMPDIR}/repo"

FILE="confs/app/deployment.yaml"
[[ -f "$FILE" ]] || { echo -e "${RED}absent: $FILE${NC}"; exit 1; }

sed -i -E 's#(wil42/playground:)(v1|v2)#\1'"${TAG}"'#' "$FILE"

git config user.email "${GIT_USER:-iot-p3}@local"
git config user.name "${GIT_USER:-iot-p3}"
git add "$FILE"
git commit -m "chore(app): set wil42/playground:${TAG}"
git push origin HEAD
echo -e "${GREEN}Git push OK wil42/playground:${TAG}${NC}"

kubectl -n argocd patch application iot-playground \
	--type=merge \
	-p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
