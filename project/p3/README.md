# Checklist conformité P3 – K3d & ArgoCD

### Exigences du sujet

| Exigences                                  | Statut | Commande Makefile    | Où regarder / Résultat attendu                                         |
| ------------------------------------------ | :----: | -------------------- | ---------------------------------------------------------------------- |
| VM avec Docker, kubectl, k3d, git, curl    |    ✅   | `make doctor`        | Tous les outils listés avec ✔ et version correcte                      |
| Cluster K3d créé et fonctionnel            |    ✅   | `make status`        | Bloc **== Cluster ==** avec infos cluster et au moins 1 node en Ready  |
| Namespace `argocd` créé                    |    ✅   | `make status`        | Bloc **== Cluster ==** → `argocd Active`                               |
| Namespace `dev` créé                       |    ✅   | `make status`        | Bloc **== Cluster ==** → `dev Active`                                  |
| Argo CD installé via manifeste stable      |    ✅   | `make status`        | Bloc **== Pods ArgoCD ==** : tous Running/Ready                        |
| Application ArgoCD créée                   |    ✅   | `make status`        | Bloc **== Application Argo ==** : présence de `iot-playground`         |
| Application ArgoCD Synced & Healthy        |    ✅   | `make status`        | Bloc **== Application Argo ==** : `SYNCED` et `HEALTHY`                |
| Dépôt GitHub public configuré              |    ✅   | `make status`        | Bloc **== Application Argo ==** ou Argo UI → `repoURL` = GitHub public |
| Nom du repo contient login 42 (`cedmulle`) |    ✅   | Vérif visuelle       | `cedmulle-42iot` affiché dans ArgoCD UI ou YAML                        |
| Application déployée dans namespace `dev`  |    ✅   | `make status`        | Bloc **== Pods Application (dev) ==** : pods Running                   |
| Service ClusterIP exposé sur port 8888     |    ✅   | `make status`        | Bloc **== Check Application ==** : connexion sur `8888` OK             |
| Version initiale = **v1**                  |    ✅   | `make up`            | Sortie finale du script → `{"message":"v1"}`                           |
| Switch vers **v2** via GitOps              |    ✅   | `make set-version-2` | Affiche `Git push OK wil42/playground:v2` et refresh Argo              |
| Version appli mise à jour = **v2**         |    ✅   | `make status`        | Bloc **== Check Application ==** → `{"message":"v2"}`                  |


### Ajout de fonctionnalités

| Ajouts                                  | Statut | Commande Makefile | Où regarder / Résultat attendu                                    |
| --------------------------------------- | :----: | ----------------- | ----------------------------------------------------------------- |
| Script installe/revérifie les prérequis |    ✅   | `make up`         | Logs `[install] docker present OK`, `[install] k3d present`, etc. |
| Accès UI ArgoCD local (port 8080)       |    ✅   | `make portfw`     | `https://localhost:8080` → login `admin` + mot de passe fourni    |
| Nettoyage appli `dev`                   |    ✅   | `make clean`      | `make status` → Bloc **== Pods Application (dev) ==** vide        |
| Suppression complète cluster            |    ✅   | `make nuke`       | `make status` → cluster inaccessible (erreur)                     |
