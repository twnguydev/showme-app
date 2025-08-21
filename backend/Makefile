.PHONY: help dev prod stop clean logs shell backup restore monitoring

# Variables
COMPOSE = docker-compose
ENV_FILE = .env
BACKUP_DIR = ./backups
LOG_DIR = ./logs

# Couleurs pour les messages
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help: ## Afficher l'aide
	@echo "$(BLUE)🚀 qard Backend - Commandes disponibles:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(BLUE)📊 URLs de développement:$(NC)"
	@echo "  API:          http://localhost:3000"
	@echo "  PHPMyAdmin:   http://localhost:8080"
	@echo "  Grafana:      http://localhost:3001 (admin/admin123)"
	@echo "  Prometheus:   http://localhost:9090"

dev: ## Démarrer l'environnement de développement
	@echo "$(GREEN)🔧 Démarrage en mode développement...$(NC)"
	@$(COMPOSE) up -d mysql redis
	@echo "$(YELLOW)⏳ Attente des services...$(NC)"
	@sleep 15
	@$(COMPOSE) up -d phpmyadmin mysql-backup
	@$(COMPOSE) up -d --build app
	@echo "$(GREEN)✅ Environnement de développement prêt!$(NC)"

prod: ## Démarrer en mode production avec monitoring
	@echo "$(GREEN)🚀 Démarrage en mode production...$(NC)"
	@export NODE_ENV=production && $(COMPOSE) up -d --build
	@echo "$(GREEN)✅ Production démarrée avec monitoring!$(NC)"

stop: ## Arrêter tous les services
	@echo "$(RED)🛑 Arrêt des services...$(NC)"
	@$(COMPOSE) down

restart: ## Redémarrer tous les services
	@echo "$(YELLOW)🔄 Redémarrage des services...$(NC)"
	@$(COMPOSE) restart

clean: ## Nettoyer complètement (⚠️ SUPPRIME LES DONNÉES)
	@echo "$(RED)🗑️  ATTENTION: Cette action va supprimer toutes les données!$(NC)"
	@read -p "Êtes-vous sûr? [y/N]: " confirm && [ "$$confirm" = "y" ]
	@$(COMPOSE) down -v --remove-orphans
	@docker system prune -f
	@echo "$(RED)✅ Nettoyage terminé$(NC)"

logs: ## Afficher les logs de tous les services
	@$(COMPOSE) logs -f

logs-app: ## Afficher les logs de l'application uniquement
	@$(COMPOSE) logs -f app

logs-mysql: ## Afficher les logs MySQL
	@$(COMPOSE) logs -f mysql

logs-backup: ## Afficher les logs de backup
	@$(COMPOSE) logs -f mysql-backup

status: ## Afficher le statut des services
	@echo "$(BLUE)📊 Statut des services:$(NC)"
	@$(COMPOSE) ps

shell-app: ## Accéder au shell de l'application
	@$(COMPOSE) exec app sh

shell-mysql: ## Accéder au shell MySQL
	@$(COMPOSE) exec mysql mysql -u$${DB_USER} -p$${DB_PASSWORD} $${DB_NAME}

shell-redis: ## Accéder au shell Redis
	@$(COMPOSE) exec redis redis-cli

backup: ## Créer un backup manuel de la base de données
	@echo "$(GREEN)💾 Création du backup...$(NC)"
	@$(COMPOSE) exec mysql-backup /backup.sh
	@echo "$(GREEN)✅ Backup créé dans $(BACKUP_DIR)$(NC)"

backup-list: ## Lister les backups disponibles
	@echo "$(BLUE)📋 Backups disponibles:$(NC)"
	@ls -la $(BACKUP_DIR)/*.sql 2>/dev/null || echo "$(YELLOW)Aucun backup trouvé$(NC)"

restore: ## Restaurer la base de données depuis un backup
	@echo "$(BLUE)📋 Backups disponibles:$(NC)"
	@ls -la $(BACKUP_DIR)/*.sql 2>/dev/null || echo "$(RED)Aucun backup trouvé$(NC)"
	@read -p "Nom du fichier de backup (sans le chemin): " backup_file; \
	if [ -f "$(BACKUP_DIR)/$$backup_file" ]; then \
		echo "$(YELLOW)🔄 Restauration en cours...$(NC)"; \
		$(COMPOSE) exec -T mysql mysql -u$${DB_USER} -p$${DB_PASSWORD} $${DB_NAME} < $(BACKUP_DIR)/$$backup_file; \
		echo "$(GREEN)✅ Restauration terminée$(NC)"; \
	else \
		echo "$(RED)❌ Fichier non trouvé$(NC)"; \
	fi

migration-generate: ## Générer une nouvelle migration
	@echo "$(GREEN)🗄️ Génération d'une nouvelle migration...$(NC)"
	@read -p "Nom de la migration: " name; \
	$(COMPOSE) exec app npm run typeorm -- migration:generate src/database/migrations/$$name

migration-create: ## Créer une migration vide
	@echo "$(GREEN)🗄️ Création d'une migration vide...$(NC)"
	@read -p "Nom de la migration: " name; \
	$(COMPOSE) exec app npm run typeorm -- migration:create src/database/migrations/$$name

migration-run: ## Exécuter les migrations
	@echo "$(GREEN)🗄️ Exécution des migrations...$(NC)"
	@$(COMPOSE) exec app npm run typeorm -- migration:run

migration-revert: ## Annuler la dernière migration
	@echo "$(YELLOW)↩️ Annulation de la dernière migration...$(NC)"
	@$(COMPOSE) exec app npm run typeorm -- migration:revert

migration-show: ## Afficher le statut des migrations
	@echo "$(BLUE)📋 Statut des migrations:$(NC)"
	@$(COMPOSE) exec app npm run typeorm -- migration:show

# Commande de debug TypeORM
typeorm-debug: ## Debug de la configuration TypeORM
	@echo "$(BLUE)🔍 Test de la configuration TypeORM...$(NC)"
	@$(COMPOSE) exec app node -e "
		const { AppDataSource } = require('./dist/config/typeorm.config.js');
		console.log('Configuration TypeORM:');
		console.log('- Type:', AppDataSource.options.type);
		console.log('- Host:', AppDataSource.options.host);
		console.log('- Database:', AppDataSource.options.database);
		console.log('- Entities:', AppDataSource.options.entities.length);
	"

seed: ## Peupler la base avec des données de test
	@echo "$(GREEN)🌱 Ajout des données de test...$(NC)"
	@npm run seed

# Commandes de développement
setup-db: ## Configuration complète de la base de données
	@echo "$(GREEN)🗄️ Configuration de la base de données...$(NC)"
	@$(COMPOSE) up -d mysql
	@echo "$(YELLOW)⏳ Attente de MySQL...$(NC)"
	@sleep 15
	@make migration-run
	@make seed
	@echo "$(GREEN)✅ Base de données configurée!$(NC)"

reset-db-full: ## Reset complet avec nouvelles migrations
	@echo "$(RED)⚠️ ATTENTION: Reset complet de la base!$(NC)"
	@read -p "Êtes-vous sûr? [y/N]: " confirm && [ "$$confirm" = "y" ]
	@$(COMPOSE) stop mysql app
	@docker volume rm qard_mysql_data 2>/dev/null || true
	@$(COMPOSE) up -d mysql
	@sleep 15
	@make migration-run
	@make seed
	@$(COMPOSE) up -d app
	@echo "$(GREEN)✅ Base de données réinitialisée avec migrations!$(NC)"

monitoring: ## Démarrer uniquement le monitoring
	@echo "$(GREEN)📊 Démarrage du monitoring...$(NC)"
	@$(COMPOSE) up -d prometheus grafana node-exporter loki promtail
	@echo "$(GREEN)✅ Monitoring démarré!$(NC)"
	@echo "$(BLUE)📊 Grafana: http://localhost:3001$(NC)"
	@echo "$(BLUE)📊 Prometheus: http://localhost:9090$(NC)"

monitoring-stop: ## Arrêter le monitoring
	@echo "$(RED)📊 Arrêt du monitoring...$(NC)"
	@$(COMPOSE) stop prometheus grafana node-exporter loki promtail

health: ## Vérifier la santé des services
	@echo "$(BLUE)🔍 Vérification de la santé des services:$(NC)"
	@echo ""
	@echo "$(YELLOW)MySQL:$(NC)"
	@$(COMPOSE) exec mysql mysqladmin ping -h localhost --silent && echo "$(GREEN)✅ MySQL OK$(NC)" || echo "$(RED)❌ MySQL KO$(NC)"
	@echo ""
	@echo "$(YELLOW)Redis:$(NC)"
	@$(COMPOSE) exec redis redis-cli ping | grep PONG > /dev/null && echo "$(GREEN)✅ Redis OK$(NC)" || echo "$(RED)❌ Redis KO$(NC)"
	@echo ""
	@echo "$(YELLOW)Application:$(NC)"
	@curl -f http://localhost:3000/health > /dev/null 2>&1 && echo "$(GREEN)✅ App OK$(NC)" || echo "$(RED)❌ App KO$(NC)"

rebuild: ## Reconstruire et redémarrer tous les services
	@echo "$(YELLOW)🔨 Reconstruction des services...$(NC)"
	@$(COMPOSE) down
	@$(COMPOSE) build --no-cache
	@$(COMPOSE) up -d
	@echo "$(GREEN)✅ Services reconstruits$(NC)"

update: ## Mettre à jour les images Docker
	@echo "$(GREEN)⬆️ Mise à jour des images...$(NC)"
	@$(COMPOSE) pull
	@$(COMPOSE) up -d

db-reset: ## Réinitialiser complètement la base de données
	@echo "$(RED)⚠️ ATTENTION: Cette action va supprimer toutes les données de la base!$(NC)"
	@read -p "Êtes-vous sûr? [y/N]: " confirm && [ "$$confirm" = "y" ]
	@$(COMPOSE) stop mysql app
	@docker volume rm qard_mysql_data 2>/dev/null || true
	@$(COMPOSE) up -d mysql
	@sleep 15
	@$(COMPOSE) up -d app
	@echo "$(GREEN)✅ Base de données réinitialisée$(NC)"

start: dev
up: dev
down: stop