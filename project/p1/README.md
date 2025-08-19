# Checklist conformité P1 - Vagrant & K3s

### Setup

1. Configurer la variable d'environnement `cp .env.example .env` et modifier le .env pour ajouter un token
2. Preparer script d'installation de K3s `chmod +x scripts/*.sh`
3. Lancer le projet `make up`

<br>

### Exigences du sujet

| Exigences du sujet P1                                | Statut  | Commande Makefile     | Où regarder / Résultat attendu                                             |
| ---------------------------------------------------- | :-----: | --------------------- | -------------------------------------------------------------------------- |
| Utilisation de **Vagrant** avec VirtualBox           |    ✅   | `make up`             | Les VM démarrent via `Vagrantfile` (provider VirtualBox).                  |
| Deux VMs distinctes : **controller** & **worker**    |    ✅   | `make status`         | Affiche `cedmulleS running` et `cedmulleSW running`.                       |
| Réseau privé configuré avec IP fixes                 |    ✅   | `make check-ip`       | Affiche l’IP privée de chaque VM (192.168.56.110 / 192.168.56.111).        |
| Authentification SSH sur controller                  |    ✅   | `make ssh-controller` | Connexion SSH sans mot de passe sur controller.                            |
| Authentification SSH sur worker                      |    ✅   | `make ssh-worker`     | Connexion SSH sans mot de passe sur worker.                                |
| Installation de K3s sur **controller** et **worker** |    ✅   | `make k3s-status`     | `[Controller]` → `active (running)` et `[Worker]` → `active (running)`     |
| Utilisation d’un **token K3S partagé**               |    ✅   | `.env`                | Fichier `.env` contient `K3S_TOKEN=...`. Abandon si vide.                  |
| Attente de disponibilité du controller (port 6443)   |    ✅   | `make up` (logs)      | Log `En attente de 192.168.56.110:6443` avant l’install worker.            |
| Détruire et recréer les VM facilement                |    ✅   | `make destroy`        | `vagrant destroy -f` supprime tout.                                        |

<br>

### Ajout de fonctionnalités

| Ajout                                              | Commande Makefile                         | Où regarder / Résultat attendu                                            |
| -------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------- |
| Makefile centralisé avec couleurs et aide intégrée | `make help`                               | Affiche toutes les commandes dispos avec un menu coloré.                  |
| Vérification rapide du statut des VM               | `make status`                             | Affiche `running`/`poweroff` pour `cedmulleS` et `cedmulleSW`.            |
| Connexion rapide en SSH                            | `make ssh-controller` / `make ssh-worker` | Ouvre directement une session SSH vers la VM correspondante.              |
| Affichage des IP privées                           | `make check-ip`                           | Retourne les IP fixes configurées (192.168.56.110 / 192.168.56.111).      |
| Vérification centralisée du statut K3s             | `make k3s-status`                         | Affiche l’état des services `k3s`/`k3s-server` et `k3s-agent`.            |
| Affichage des nœuds Kubernetes                     | `make kubectl-nodes`                      | Affiche la liste des nœuds via `kubectl get nodes -o wide`.               |
| Fichier `.env.example` fourni                      | —                                         | Facilite la configuration en montrant le champ `K3S_TOKEN=` à remplir.    |
| Provisionnement automatisé des paquets de base     | `make up`                                 | Dans `Vagrantfile` → installation auto de `curl` et `netcat-openbsd`.     |
