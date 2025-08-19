.PHONY: help up halt destroy status ssh-controller ssh-worker check-ip kubectl-nodes k3s-status

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
GREY=\033[2;37m
NC=\033[0m

help:
	@echo "$(CYAN)Commandes disponibles :$(NC)"
	@echo "  $(GREEN)make up$(NC)              $(GREY)# Démarre les deux VM (Vagrant up)$(NC)"
	@echo "  $(GREEN)make halt$(NC)            $(GREY)# Arrête les deux VM (Vagrant halt)$(NC)"
	@echo "  $(GREEN)make destroy$(NC)         $(GREY)# Détruit les deux VM (Vagrant destroy)$(NC)"
	@echo "  $(GREEN)make status$(NC)          $(GREY)# Affiche le statut des VM (Vagrant status)$(NC)"
	@echo "  $(GREEN)make ssh-controller$(NC)  $(GREY)# Se connecter en SSH sur la VM controller (cedmulleS)$(NC)"
	@echo "  $(GREEN)make ssh-worker$(NC)      $(GREY)# Se connecter en SSH sur la VM worker (cedmulleSW)$(NC)"
	@echo "  $(GREEN)make check-ip$(NC)        $(GREY)# Affiche les IP de la VM controller et worker$(NC)"
	@echo "  $(GREEN)make kubectl-nodes$(NC)   $(GREY)# Affiche les nœuds Kubernetes (kubectl get nodes -o wide)$(NC)"
	@echo "  $(GREEN)make k3s-status$(NC)      $(GREY)# Vérifie le status de k3s sur les deux VM$(NC)"

up:
	@echo "$(YELLOW)Démarrage des VMs...$(NC)"
	@vagrant up

halt:
	@echo "$(YELLOW)Arrêt des VMs...$(NC)"
	@vagrant halt

destroy:
	@echo "$(YELLOW)Destruction des VMs...$(NC)"
	@vagrant destroy -f
	@rm -rf .vagrant

status:
	@echo "$(YELLOW)Statut des VMs...$(NC)"
	@vagrant status

ssh-controller:
	@echo "$(YELLOW)Connexion en cours sur le controller cedmulleS...$(NC)"
	@vagrant ssh cedmulleS

ssh-worker:
	@echo "$(YELLOW)Connexion en cours sur le worker cedmulleSW...$(NC)"
	@vagrant ssh cedmulleSW

check-ip:
	@echo "$(YELLOW)[Controller]$(NC)"
	@vagrant ssh cedmulleS -c "hostname -I | tr ' ' '\n' | grep '^192\.'"
	@echo ""
	@echo "$(YELLOW)[Worker]$(NC)"
	@vagrant ssh cedmulleSW -c "hostname -I | tr ' ' '\n' | grep '^192\.'"
	@echo ""

kubectl-nodes:
	@echo "$(YELLOW)Affichage des nœuds Kubernetes...$(NC)"
	@vagrant ssh cedmulleS -c "kubectl get nodes -o wide"

k3s-status:
	@echo "$(YELLOW)[Controller]$(NC)"
	@vagrant ssh cedmulleS -c "sudo systemctl status k3s || sudo systemctl status k3s-server"
	@echo ""
	@echo "$(YELLOW)[Worker]$(NC)"
	@vagrant ssh cedmulleSW -c "sudo systemctl status k3s-agent || sudo systemctl status k3s"
	@echo ""
