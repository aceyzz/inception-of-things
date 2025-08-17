#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

K3D_CLUSTER_NAME="iot-p3"
ARGO_NAMESPACE="argocd"
APP_NAMESPACE="dev"
ARGO_STABLE_MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

log() { printf "\n\033[1;34m[install]\033[0m %s\n" "$*"; }
warn() { printf "\n\033[1;33m[warning]\033[0m %s\n" "$*"; }
die() { printf "\n\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }
have_cmd() { command -v "$1" >/dev/null 2>&1; }

can_sudo=false
if have_cmd sudo && sudo -n true >/dev/null 2>&1; then
  can_sudo=true
fi

apt_install() {
"$can_sudo" || die "installation de paquets impossible : droits root requis"
  sudo apt-get update -y
  sudo apt-get install -y "$@"
}

require_tool_or_fail() {
  local bin="$1" hint="$2"
have_cmd "$bin" || die "outil manquant : $bin. $hint"
}

load_env() {
  if [[ -f "${ENV_FILE}" ]]; then
    set -a
    . "${ENV_FILE}"
    set +a
  fi
}

wait_pods_ready() {
  local ns="$1"; local timeout="${2:-180}"
log "attente que les pods soient prets ns=${ns} timeout=${timeout}s"
  local start end
  start=$(date +%s)
  while true; do
    local lines
    lines=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l | tr -d ' ')
    if [[ "${lines}" -eq 0 ]]; then
      :
    else
      local not_ok
      not_ok=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | awk '{print $2" "$3}' | grep -vE '^[1-9][0-9]*/[1-9][0-9]* Running$' || true)
      if [[ -z "$not_ok" ]]; then
        log "pods OK ns=${ns}"
        return 0
      fi
    fi
    end=$(date +%s)
	(( end - start > timeout )) && die "pods ne sont pas prets dans le namespace ${ns} apres ${timeout}s"
    sleep 3
  done
}

wait_argocd_app_synced() {
  local app="$1"; local timeout="${2:-180}"
log "attente que argocd app=${app} soit synchro et saine (timeout=${timeout}s)"
  local start end
  start=$(date +%s)
  while true; do
    local phase health
    phase=$(kubectl -n "${ARGO_NAMESPACE}" get applications.argoproj.io "${app}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)
    health=$(kubectl -n "${ARGO_NAMESPACE}" get applications.argoproj.io "${app}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)
    if [[ "$phase" == "Synced" && "$health" == "Healthy" ]]; then
      log "app ${app} synchro et saine"
      return 0
    fi
    end=$(date +%s)
	(( end - start > timeout )) && die "application ${app} n'est pas synchro et saine apres ${timeout}s phase=${phase} health=${health}"
    sleep 3
  done
}

ensure_network() {
  log "check reseau github.com et docker hub"
  curl -sSfL https://github.com >/dev/null
  status=$(curl -sSI https://registry-1.docker.io/v2/ | awk 'NR==1{print $2}')
  case "$status" in
    200|401) log "docker hub joignable" ;;
    *) die "docker hub injoignable" ;;
  esac
}

install_basics() {
  if have_cmd curl && have_cmd git; then
    log "basics OK"
    return
  fi
  if "$can_sudo" && have_cmd apt-get; then
    log "install basics"
    apt_install curl ca-certificates git
else
	require_tool_or_fail curl "installez curl manuellement ou executez ce script avec sudo"
	require_tool_or_fail git "installez git manuellement ou executez ce script avec sudo"
  fi
}

install_docker() {
  if have_cmd docker; then
    log "docker present OK"
    return
  fi
  if "$can_sudo" && have_cmd apt-get; then
    log "install docker"
    apt_install apt-transport-https gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
    . /etc/os-release
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    apt_install docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    if ! groups "$USER" | grep -q docker; then
      log "ajout de $USER au groupe docker"
      sudo usermod -aG docker "$USER" || true
    fi
    sudo docker run --rm hello-world >/dev/null 2>&1 || sudo docker run --rm hello-world >/dev/null
else
	require_tool_or_fail docker "installez docker manuellement ou executez ce script avec sudo"
  fi
}

install_kubectl() {
  if have_cmd kubectl; then
    log "kubectl present ok"
    return
  fi
  if "$can_sudo"; then
    log "install kubectl"
    KVER=$(curl -sS https://dl.k8s.io/release/stable.txt)
    curl -fsSLo kubectl "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/kubectl
    kubectl version --client >/dev/null
  else
    require_tool_or_fail kubectl "installez kubectl manuellement ou executez ce script avec sudo"
  fi
}

install_k3d() {
  if have_cmd k3d; then
    log "k3d present"
    return
  fi
  if "$can_sudo"; then
    log "install k3d"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    k3d version >/dev/null
  else
    require_tool_or_fail k3d "installez k3d manuellement ou executez ce script avec sudo"
  fi
}

create_cluster() {
  if k3d cluster list | grep -q "^${K3D_CLUSTER_NAME}\b"; then
    log "cluster ${K3D_CLUSTER_NAME} existe"
  else
    log "creation cluster ${K3D_CLUSTER_NAME}"
    k3d cluster create "${K3D_CLUSTER_NAME}"
  fi
  kubectl cluster-info >/dev/null
  kubectl get nodes >/dev/null
}

setup_namespaces() {
  log "creation namespaces ${ARGO_NAMESPACE} ${APP_NAMESPACE}"
  kubectl get ns "${ARGO_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${ARGO_NAMESPACE}"
  kubectl get ns "${APP_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${APP_NAMESPACE}"
}

install_argocd() {
  log "install argo cd"
  kubectl apply -n "${ARGO_NAMESPACE}" -f "${ARGO_STABLE_MANIFEST}"
  wait_pods_ready "${ARGO_NAMESPACE}" 300
}

apply_argocd_app() {
  log "appliquer argo application"
  kubectl apply -f "$(dirname "$0")/../confs/argocd-app.yaml"
  for i in {1..30}; do
    kubectl -n "${ARGO_NAMESPACE}" get applications.argoproj.io iot-playground >/dev/null 2>&1 && break
    sleep 2
    [[ $i -eq 30 ]] && die "application argocd iot-playground introuvable"
  done
  wait_argocd_app_synced "iot-playground" 300
}

get_expected_tag_from_deploy() {
  local image
  image=$(kubectl -n "${APP_NAMESPACE}" get deploy playground-deploy -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)
  [[ -z "$image" ]] && die "impossible de lire l'image depuis le deploiement playground-deploy"
  echo "${image##*:}"
}

test_app_matches_expected() {
  local expected_tag="$1"
  log "test app avec version attendue: ${expected_tag}"
  set +e
  kubectl -n "${APP_NAMESPACE}" port-forward svc/playground-svc 8888:8888 >/tmp/pf.log 2>&1 &
  PF_PID=$!
  set -e
  for i in {1..30}; do
    curl -sSf http://localhost:8888/ >/dev/null 2>&1 && break
    sleep 1
    [[ $i -eq 30 ]] && { kill "$PF_PID" 2>/dev/null || true; die "port-forward 8888 indisponible"; }
  done
  out=$(curl -sSf http://localhost:8888/)
  kill "$PF_PID" 2>/dev/null || true
  echo "$out" | grep -q "\"message\": \"${expected_tag}\"" || die "reponse inattendue - attendu: ${expected_tag} - obtenu: $out"
  log "OK ${out}"
}

main() {
  ensure_network
  install_basics
  install_docker
  install_kubectl
  install_k3d
  create_cluster
  setup_namespaces
  install_argocd
  apply_argocd_app
  expected="$(get_expected_tag_from_deploy)"
  test_app_matches_expected "${expected}"
  log "installation terminee avec succes"
}

main "$@"
