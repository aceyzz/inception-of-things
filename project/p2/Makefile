
.PHONY: help up halt destroy status ssh check-ip check-eth1 check-hostname k3s-status k3s-logs deploy-apps delete-apps get-pods get-services get-ingress get-all test-apps

# colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
GREY=\033[2;37m
NC=\033[0m


help:
	@echo "$(CYAN)Commandes disponibles :$(NC)"
	@echo "  $(GREEN)make up$(NC)              $(GREY)# Démarre la VM (vagrant up)$(NC)"
	@echo "  $(GREEN)make halt$(NC)            $(GREY)# Arrête la VM (vagrant halt)$(NC)"
	@echo "  $(GREEN)make destroy$(NC)         $(GREY)# Détruit la VM (vagrant destroy -f) et supprime .vagrant$(NC)"
	@echo "  $(GREEN)make status$(NC)          $(GREY)# Affiche le statut de la VM (vagrant status)$(NC)"
	@echo "  $(GREEN)make ssh$(NC)             $(GREY)# Se connecter en SSH sur la VM (vagrant ssh)$(NC)"
	@echo "  $(GREEN)make check-ip$(NC)        $(GREY)# Affiche l'IPV4 de la VM$(NC)"
	@echo "  $(GREEN)make check-hostname$(NC)  $(GREY)# Affiche le hostname de la VM$(NC)"
	@echo "  $(GREEN)make k3s-status$(NC)      $(GREY)# Vérifie le status de k3s sur la VM$(NC)"
	@echo "  $(GREEN)make k3s-logs$(NC)        $(GREY)# Affiche les logs récents de k3s sur la VM$(NC)"
	@echo "  $(GREEN)make deploy-apps$(NC)     $(GREY)# Déploie les 3 applications et l'ingress sur K3s$(NC)"
	@echo "  $(GREEN)make get-pods$(NC)        $(GREY)# Affiche les pods déployés (kubectl get pods)$(NC)"
	@echo "  $(GREEN)make get-services$(NC)    $(GREY)# Affiche les services déployés (kubectl get svc)$(NC)"
	@echo "  $(GREEN)make test-apps$(NC)       $(GREY)# Teste l'accès aux applications via curl (HOST)$(NC)"


up:
	@echo "$(YELLOW)Démarrage de la VM...$(NC)"
	@vagrant up

halt:
	@echo "$(YELLOW)Arrêt de la VM...$(NC)"
	@vagrant halt

destroy:
	@echo "$(YELLOW)Destruction de la VM...$(NC)"
	@vagrant destroy -f
	@rm -rf .vagrant

status:
	@echo "$(YELLOW)Statut de la VM...$(NC)"
	@vagrant status

ssh:
	@echo "$(YELLOW)Connexion en cours sur la VM...$(NC)"
	@vagrant ssh

check-ip:
	@echo "$(YELLOW)IPV4 de la VM :$(NC)"
	@vagrant ssh -c "ip -4 -o addr show | awk '{print $$4}' | cut -d/ -f1 | grep '192'"

check-hostname:
	@echo "$(YELLOW)Hostname de la VM :$(NC)"
	@vagrant ssh -c "hostname"

k3s-status:
	@echo "$(YELLOW)Status de k3s...$(NC)"
	@vagrant ssh -c "sudo systemctl status k3s || sudo systemctl status k3s-server"

k3s-logs:
	@echo "$(YELLOW)Logs de k3s...$(NC)"
	@vagrant ssh -c "sudo journalctl -u k3s -n 50"

deploy-apps:
	@echo "$(YELLOW)Déploiement des applications et de l'ingress...$(NC)"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app1-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app1-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app2-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app2-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app3-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app3-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/ingress.yaml"

get-pods:
	@echo "$(YELLOW)Pods déployés :$(NC)"
	@vagrant ssh -c "kubectl get pods -o wide"

get-services:
	@echo "$(YELLOW)Services déployés :$(NC)"
	@vagrant ssh -c "kubectl get svc -o wide"

test-apps:
	@echo "$(YELLOW)Test accès app1.com :$(NC)"
	@vagrant ssh -c "curl -H 'Host: app1.com' http://192.168.56.110"
	@echo "$(YELLOW)Test accès app2.com :$(NC)"
	@vagrant ssh -c "curl -H 'Host: app2.com' http://192.168.56.110"
	@echo "$(YELLOW)Test accès app3.com (défaut) :$(NC)"
	@vagrant ssh -c "curl -H 'Host: autre.com' http://192.168.56.110"
