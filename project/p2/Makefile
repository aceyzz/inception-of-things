
.PHONY: help up halt destroy status ssh check-ip k3s-status deploy-apps get-services get-ingress test-apps

# colors
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
GREY=\033[2;37m
NC=\033[0m


help:
	@echo ""
	@echo "$(CYAN)Commandes disponibles :$(NC)"
	@echo "  $(GREEN)make up$(NC)              $(GREY)# Démarrage de la VM (vagrant up)$(NC)"
	@echo "  $(GREEN)make halt$(NC)            $(GREY)# Arrêt de la VM (vagrant halt)$(NC)"
	@echo "  $(GREEN)make destroy$(NC)         $(GREY)# Destruction de la VM (vagrant destroy -f) et suppression de .vagrant$(NC)"
	@echo "  $(GREEN)make status$(NC)          $(GREY)# Statut de la VM (vagrant status)$(NC)"
	@echo "  $(GREEN)make ssh$(NC)             $(GREY)# Connexion SSH à la VM (vagrant ssh)$(NC)"
	@echo "  $(GREEN)make check-ip$(NC)        $(GREY)# Affiche l'IPV4 de la VM$(NC)"
	@echo "  $(GREEN)make k3s-status$(NC)      $(GREY)# Vérifie le status de k3s sur la VM$(NC)"
	@echo "  $(GREEN)make kubectl-nodes$(NC)   $(GREY)# Affiche les nœuds kubectl et les ressources kube-system$(NC)"
	@echo "  $(GREEN)make get-ingress$(NC)     $(GREY)# Affiche les ingress déployés (kubectl get/describe ingress)$(NC)"
	@echo "  $(GREEN)make get-services$(NC)    $(GREY)# Affiche les services déployés (kubectl get svc)$(NC)"
	@echo "  $(GREEN)make deploy-apps$(NC)     $(GREY)# Déploie les 3 applications et l'ingress sur K3s$(NC)"
	@echo "  $(GREEN)make test-apps$(NC)       $(GREY)# Teste l'accès aux applications via curl (HOST)$(NC)"
	@echo ""

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

k3s-status:
	@echo "$(YELLOW)Status de k3s...$(NC)"
	@vagrant ssh -c "sudo systemctl status k3s || sudo systemctl status k3s-server"

kubectl-nodes:
	@echo "$(YELLOW)Status des nodes...$(NC)"
	@vagrant ssh -c "kubectl get nodes -o wide"
	@echo ""
	@echo "$(YELLOW)Affichage des ressources dans kube-system et des 3 applications déployées$(NC)"
	@vagrant ssh -c "kubectl get all -n kube-system"
	@echo ""

get-ingress:
	@echo "$(YELLOW)Récupération de l'ingress...$(NC)"
	@vagrant ssh -c "kubectl get ingress -o wide"
	@echo ""
	@echo "$(YELLOW)Description de l'ingress...$(NC)"
	@vagrant ssh -c "kubectl describe ingress"
	@echo ""

get-services:
	@echo "$(YELLOW)Services déployés :$(NC)"
	@vagrant ssh -c "kubectl get svc -o wide"

deploy-apps:
	@echo "$(YELLOW)Déploiement des applications et de l'ingress...$(NC)"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app1-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app1-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app2-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app2-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app3-deployment.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/app3-service.yaml"
	@vagrant ssh -c "kubectl apply -f /vagrant/confs/ingress.yaml"

test-apps:
	@echo "$(YELLOW)Test accès app1.com :$(NC)"
	@vagrant ssh -c "curl -H 'Host: app1.com' http://192.168.56.110"
	@echo "$(YELLOW)Test accès app2.com :$(NC)"
	@vagrant ssh -c "curl -H 'Host: app2.com' http://192.168.56.110"
	@echo "$(YELLOW)Test accès app3.com (défaut) :$(NC)"
	@vagrant ssh -c "curl -H 'Host: autre.com' http://192.168.56.110"
