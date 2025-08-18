# Checklist conformité P1 - Vagrant & K3s

### Exigences du sujet

| Exigences du sujet P1                                | Statut | Commande Makefile     | Où regarder / Résultat attendu                                             |
| ---------------------------------------------------- | :----: | --------------------- | -------------------------------------------------------------------------- |
| Utilisation de **Vagrant** avec VirtualBox           |    ✅   | `make up`             | Les VM démarrent via `Vagrantfile` (provider VirtualBox).                  |
| Deux VMs distinctes : **controller** & **worker**    |    ✅   | `make status`         | Affiche `cduffautS running` et `cduffautSW running`.                       |
| Chaque VM a un **hostname unique**                   |    ✅   | `make ssh-controller` | Shell → `vagrant@cduffautS`. <br>`make ssh-worker` → `vagrant@cduffautSW`. |
| Réseau privé configuré avec IP fixes                 |    ✅   | `make ip-controller`  | Affiche `192.168.56.110`. <br>`make ip-worker` → `192.168.56.111`.         |
| Authentification SSH avec **clé publique copiée**    |    ✅   | `make ssh-controller` | Vérifier `~/.ssh/authorized_keys` contient la clé fournie.                 |
| Installation de K3s sur **controller**               |    ✅   | `make k3s-status`     | `[Controller]` → `active (running)` pour `k3s-server`.                     |
| Installation de K3s sur **worker**, joint au cluster |    ✅   | `make k3s-status`     | `[Worker]` → `active (running)` pour `k3s-agent`.                          |
| Utilisation d’un **token K3S partagé**               |    ✅   | `.env`                | Fichier `.env` contient `K3S_TOKEN=...`. Abandon si vide.                  |
| Attente de disponibilité du controller (port 6443)   |    ✅   | `make up` (logs)      | Log `En attente de 192.168.56.110:6443` avant l’install worker.            |
| Détruire et recréer les VM facilement                |    ✅   | `make destroy`        | `vagrant destroy -f` supprime tout.                                        |

### Ajout de fonctionnalités

| Ajout                                              | Commande Makefile                         | Où regarder / Résultat attendu                                            |
| -------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------- |
| Makefile centralisé avec couleurs et aide intégrée | `make help`                               | Affiche toutes les commandes dispos avec un menu coloré.                  |
| Vérification rapide du statut des VM               | `make status`                             | Affiche `running`/`poweroff` pour `cduffautS` et `cduffautSW`.            |
| Connexion rapide en SSH                            | `make ssh-controller` / `make ssh-worker` | Ouvre directement une session SSH vers la VM correspondante.              |
| Affichage des IP privées                           | `make ip-controller` / `make ip-worker`   | Retourne les IP fixes configurées (192.168.56.110 / 192.168.56.111).      |
| Vérification centralisée du statut K3s             | `make k3s-status`                         | Affiche en un coup d’œil l’état des services `k3s-server` et `k3s-agent`. |
| Fichier `.env.example` fourni                      | —                                         | Facilite la configuration en montrant le champ `K3S_TOKEN=` à remplir.    |
| Provisionnement automatisé des paquets de base     | `make up`                                 | Dans `Vagrantfile` → installation auto de `curl` et `netcat-openbsd`.     |
