.PHONY: up halt destroy status ssh-controller ssh-worker ip-controller ip-worker k3s-status help kubectl-nodes

RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
GREY=\033[2;37m
NC=\033[0m

help:
	@echo "$(CYAN)Commandes disponibles :$(NC)"
	@echo "  $(GREEN)make up$(NC)              # $(GREY)Démarre les deux VM (Vagrant up)$(NC)"
	@echo "  $(GREEN)make halt$(NC)            # $(GREY)Arrête les deux VM (Vagrant halt)$(NC)"
	@echo "  $(GREEN)make destroy$(NC)         # $(GREY)Détruit les deux VM (Vagrant destroy)$(NC)"
	@echo "  $(GREEN)make status$(NC)          # $(GREY)Affiche le statut des VM (Vagrant status)$(NC)"
	@echo "  $(GREEN)make ssh-controller$(NC)  # $(GREY)SSH sur la VM controller (cedmulleS)$(NC)"
	@echo "  $(GREEN)make ssh-worker$(NC)      # $(GREY)SSH sur la VM worker (cedmulleSW)$(NC)"
	@echo "  $(GREEN)make ip-controller$(NC)   # $(GREY)Affiche l'IP de la VM controller (eth1)$(NC)"
	@echo "  $(GREEN)make ip-worker$(NC)       # $(GREY)Affiche l'IP de la VM worker (eth1)$(NC)"
	@echo "  $(GREEN)make k3s-status$(NC)      # $(GREY)Vérifie le status de k3s sur les deux VM$(NC)"
	@echo "  $(GREEN)make kubectl-nodes$(NC)   # $(GREY)Affiche les nœuds Kubernetes (kubectl get nodes -o wide)$(NC)"

up:
	vagrant up

halt:
	vagrant halt

destroy:
	vagrant destroy -f

status:
	vagrant status

ssh-controller:
# 	vagrant ssh cedmulleS
	ssh -i ./ssh/controller_id_rsa vagrant@192.168.56.110

ssh-worker:
# 	vagrant ssh cedmulleSW
	ssh -i ./ssh/worker1_id_rsa vagrant@192.168.56.111

ip-controller:
# 	vagrant ssh cedmulleS -c "ip a show eth1"
	ssh -i ./ssh/controller_id_rsa vagrant@192.168.56.110 "ip a show eth1"

ip-worker:
# 	vagrant ssh cedmulleSW -c "ip a show eth1"
	ssh -i ./ssh/worker1_id_rsa vagrant@192.168.56.111 "ip a show eth1"

kubectl-nodes:
# 	vagrant ssh cedmulleS -c "kubectl get nodes -o wide"
	ssh -i ./ssh/controller_id_rsa vagrant@192.168.56.110 "kubectl get nodes -o wide"

k3s-status:
	@echo "$(YELLOW)[Controller]$(NC)"
	vagrant ssh cedmulleS -c "sudo systemctl status k3s || sudo systemctl status k3s-server"
	@echo "$(YELLOW)[Worker]$(NC)"
	vagrant ssh cedmulleSW -c "sudo systemctl status k3s-agent || sudo systemctl status k3s"