<img title="42_iot" alt="42_inception_of_things" src="./utils/banner.png" width="100%">

<br>

## Index

- [Consigne](#consigne)
- [Partie 1 - Vagrant & K3s](#p1-vagrant--k3s)
- [Partie 2 - K3s & replicas d'applications](#p2-k3s--replicas-dapplications)
- [Partie 3 - K3d & ArgoCD](#p3-k3d--argocd)

<br>

## Consigne

Ce projet **Inception of Things** (IoT) consiste à déployer une stack Kubernetes de plusieurs façons.  
Il est divisé en **3 parties indépendantes** :  

1. **Partie 1 : Vagrant & K3s**  
   - Créer deux VMs avec Vagrant (un contrôleur, un worker).  
   - Installer et configurer K3s dessus.  

2. **Partie 2 : K3s & replicas d'applications**  
   - A venir

3. **Partie 3 : K3d & ArgoCD**  
   - Déployer un cluster Kubernetes avec K3d (Docker).  
   - Installer ArgoCD et mettre en place du GitOps (déploiement auto d’une appli depuis un repo GitHub public).  

<br>

## [P1] Vagrant & K3s

[Voir exigences et implementation](./p1/README.md)

**VMs VirtualBox** créées via Vagrant.  
1 contrôleur (`cedmulleS`) et 1 worker (`cedmulleSW`).  
Réseau privé (192.168.56.x).  
K3s installé automatiquement par provisioning.  
Connexion SSH configurée via clés publiques.  

### Fonctionnalités principales
- `Vagrantfile` crée 2 VMs Ubuntu 22.04 :  
  - **cedmulleS** (controller, IP : `192.168.56.110`)  
  - **cedmulleSW** (worker, IP : `192.168.56.111`)  
- Les clés SSH sont provisionnées automatiquement (`./ssh`).  
- Installation automatique de `curl`, `nc` et `k3s` (controller + agent).  
- Le worker attend que le controller soit prêt (`nc -z IP 6443`).  

### Commandes Makefile
- `make up` : démarre les 2 VMs.  
- `make halt` : arrête les VMs.  
- `make destroy` : détruit les VMs.  
- `make status` : statut des VMs.  
- `make ssh-controller` / `make ssh-worker` : accès SSH direct.  
- `make ip-controller` / `make ip-worker` : affiche l’IP.  
- `make k3s-status` : vérifie que K3s est actif sur les deux VMs.  

### Vérifications
- Controller K3s actif : `systemctl status k3s-server`.  
- Worker relié au cluster : `systemctl status k3s-agent`.  
- Depuis controller : `kubectl get nodes` → 2 nœuds (Ready).  

<br>

## [P2] K3s & replicas d'applications

*A venir*  

<br>

## [P3] K3d & ArgoCD

[Voir exigences et implementation](./p3/README.md)

Cluster Kubernetes lancé avec **k3d** (Docker-in-Docker).  
Namespaces `argocd` et `dev`.  
ArgoCD déployé depuis manifeste officiel.  
Application GitOps (`wil42/playground`) déployée depuis repo public **cedmulle-42iot**.  
Deux versions disponibles : v1 et v2, switch via commit Git → ArgoCD sync.  
UI ArgoCD accessible en local sur `https://localhost:8080`.  

### Fonctionnalités principales
- Cluster Kubernetes lancé avec **k3d**.  
- ArgoCD déployé dans namespace `argocd`.  
- Namespace `dev` pour l’application.  
- Application ArgoCD `iot-playground` créée depuis repo public `https://github.com/aceyzz/cedmulle-42iot.git`.  
- Application expose un **Service ClusterIP** sur le port `8888`.  
- Deux versions disponibles (v1 et v2) :  
  - Version initiale = `{"message":"v1"}`  
  - Switch vers v2 via `make set-version-2`.  

### Commandes Makefile
- `make up` : installe les prérequis (docker, k3d, kubectl…), crée le cluster, déploie ArgoCD et l’application.  
- `make status` : affiche état du cluster, pods, namespaces, application ArgoCD, test HTTP sur app.  
- `make portfw` : ouvre un port-forward local → accès UI ArgoCD sur `https://localhost:8080`.  
- `make set-version-2` : bascule l’application en version 2 via GitOps.  
- `make clean` : supprime uniquement l’application dans `dev`.  
- `make nuke` : détruit complètement le cluster k3d.  

### Vérifications
- ArgoCD Synced/Healthy : `make status` → bloc Application Argo = `SYNCED, HEALTHY`.  
- Application dispo : `curl http://localhost:8888` → `{"message":"v1"}` puis `{"message":"v2"}`.  
- UI ArgoCD accessible : `make portfw` + login `admin`.  

<br>
