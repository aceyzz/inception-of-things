.PHONY: up status set-version-1 set-version-2 portfw app-start app-stop clean nuke help doctor

GREEN=\033[0;32m
YELLOW=\033[1;33m
CYAN=\033[0;36m
GREY=\033[2;37m
RESET=\033[0m

SCRIPTS=scripts

help:
	@echo "$(CYAN)Utilisation :$(RESET)"
	@echo "  $(GREEN)make up$(RESET)               $(GREY)# Démarrer et provisionner tout$(RESET)"
	@echo "  $(GREEN)make status$(RESET)           $(GREY)# Vérifier l'état du cluster et de l'application$(RESET)"
	@echo "  $(GREEN)make set-version-1$(RESET)    $(GREY)# Basculer l'application en v1 via GitOps$(RESET)"
	@echo "  $(GREEN)make set-version-2$(RESET)    $(GREY)# Basculer l'application en v2 via GitOps$(RESET)"
	@echo "  $(GREEN)make app-start$(RESET)        $(GREY)# Exposer l'application sur localhost:8080 en arrière-plan$(RESET)"
	@echo "  $(GREEN)make app-stop$(RESET)         $(GREY)# Arrêter le port-forward de l'application sur 8080$(RESET)"
	@echo "  $(GREEN)make clean$(RESET)            $(GREY)# Supprimer l'application Argo et les ressources dev$(RESET)"
	@echo "  $(GREEN)make nuke$(RESET)             $(GREY)# Supprimer le cluster k3d$(RESET)"
	@echo "  $(GREEN)make doctor$(RESET)           $(GREY)# Vérifier les prérequis$(RESET)"

up:
	@echo "$(YELLOW)Démarrage de l'application$(RESET)"
	@bash $(SCRIPTS)/install.sh

status:
	@echo "$(YELLOW)Vérification de l'état$(RESET)"
	@bash $(SCRIPTS)/check.sh

set-version-1:
	@echo "$(YELLOW)Passage à la version v1$(RESET)"
	@bash $(SCRIPTS)/set_version.sh 1

set-version-2:
	@echo "$(YELLOW)Passage à la version v2$(RESET)"
	@bash $(SCRIPTS)/set_version.sh 2

portfw:
	@echo "$(YELLOW)Redirection du port ArgoCD UI sur 8080$(RESET)"
	@bash $(SCRIPTS)/portfw.sh

app-start:
	@echo "$(YELLOW)Démarrage du port-forward de l'application sur 8080$(RESET)"
	@bash $(SCRIPTS)/app_portfw_start.sh

app-stop:
	@echo "$(YELLOW)Arrêt du port-forward de l'application sur 8080$(RESET)"
	@bash $(SCRIPTS)/app_portfw_stop.sh

clean:
	@echo "$(YELLOW)Nettoyage$(RESET)"
	@bash $(SCRIPTS)/clean.sh

nuke:
	@echo "$(YELLOW)Suppression de l'environnement$(RESET)"
	@bash $(SCRIPTS)/nuke.sh

doctor:
	@echo "$(YELLOW)Vérification des prérequis$(RESET)"
	@bash $(SCRIPTS)/doctor.sh
