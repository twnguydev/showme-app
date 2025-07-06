# ShowMe Backend API

Backend API sécurisé et scalable pour l'application ShowMe - Cartes de contact digitales.

## 🚀 Technologies

- **Backend**: NestJS + TypeScript
- **Base de données**: MySQL 8.0 avec TypeORM
- **Cache**: Redis
- **Authentification**: JWT + Refresh Tokens
- **Documentation**: Swagger/OpenAPI
- **Stockage**: AWS S3 compatible (MinIO local)
- **Conteneurisation**: Docker + Docker Compose
- **Reverse Proxy**: NGINX
- **Paiements**: Stripe

## 📋 Prérequis

- Node.js 18+ 
- Docker & Docker Compose
- npm ou yarn

## ⚡ Installation rapide

```bash
# Cloner le repository
git clone <repository-url>
cd showme-backend

# Configuration automatique
npm run setup

# Démarrer en mode développement
npm run dev
```

## 🔧 Configuration manuelle

### 1. Variables d'environnement

```bash
# Copier le fichier d'exemple
cp .env.example .env

# Modifier les variables selon votre environnement
nano .env
```

### 2. Démarrage des services

```bash
# Démarrer les services Docker (MySQL, Redis, MinIO)
docker-compose up -d mysql redis minio

# Installer les dépendances Node.js
npm install

# Exécuter les migrations de base de données
npm run migration:run

# Démarrer l'application
npm run start:dev
```

## 🐳 Docker

### Développement

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down
```

### Production

```bash
# Construire et démarrer en production
npm run prod

# Ou avec Docker seulement
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 📚 API Documentation

Une fois l'application démarrée, la documentation Swagger est disponible à :

- **Développement**: http://localhost:3000/api/docs
- **Production**: https://api.showme.app/api/docs

## 🏗️ Architecture

```
src/
├── config/              # Configuration (DB, app, etc.)
├── entities/            # Entités TypeORM
├── modules/             # Modules fonctionnels
│   ├── auth/           # Authentification
│   ├── users/          # Gestion utilisateurs
│   ├── cards/          # Cartes de contact
│   ├── analytics/      # Statistiques
│   ├── subscriptions/  # Abonnements
│   ├── payments/       # Paiements Stripe
│   ├── uploads/        # Gestion fichiers
│   └── admin/          # Panel administrateur
├── common/             # Utilitaires communs
└── database/           # Migrations et seeds
```

## 🔐 Authentification

L'API utilise JWT avec des refresh tokens pour l'authentification :

```bash
# S'enregistrer
POST /api/v1/auth/register

# Se connecter
POST /api/v1/auth/login

# Rafraîchir le token
POST /api/v1/auth/refresh

# Obtenir son profil
GET /api/v1/auth/me
```

## 🃏 Endpoints principaux

### Authentification
- `POST /api/v1/auth/register` - Créer un compte
- `POST /api/v1/auth/login` - Se connecter
- `POST /api/v1/auth/refresh` - Rafraîchir le token
- `POST /api/v1/auth/forgot-password` - Mot de passe oublié
- `POST /api/v1/auth/reset-password` - Réinitialiser le mot de passe

### Utilisateurs
- `GET /api/v1/users/me` - Mon profil
- `PUT /api/v1/users/me` - Modifier mon profil
- `PUT /api/v1/users/me/password` - Changer mon mot de passe
- `PUT /api/v1/users/me/avatar` - Uploader photo de profil

### Cartes
- `GET /api/v1/cards` - Mes cartes
- `POST /api/v1/cards` - Créer une carte
- `GET /api/v1/cards/:slug` - Voir une carte publique
- `PUT /api/v1/cards/:id` - Modifier ma carte
- `DELETE /api/v1/cards/:id` - Supprimer ma carte

### Analytics
- `GET /api/v1/analytics/cards/:id/stats` - Statistiques d'une carte
- `GET /api/v1/analytics/dashboard` - Dashboard général

## 📊 Base de données

### Migrations

```bash
# Générer une nouvelle migration
npm run migration:generate -- src/database/migrations/MigrationName

# Exécuter les migrations
npm run migration:run

# Revenir en arrière
npm run migration:revert

# Supprimer le schéma (ATTENTION)
npm run schema:drop
```

### Modèles principaux

- **User** - Utilisateurs de l'application
- **Profile** - Profils détaillés des utilisateurs
- **Card** - Cartes de contact digitales
- **ContactExchange** - Historique des partages
- **Subscription** - Abonnements Pro
- **Payment** - Paiements Stripe
- **WalletPass** - Passes Apple Wallet

## 🔧 Scripts disponibles

```bash
# Développement
npm run start:dev          # Mode développement avec hot-reload
npm run start:debug        # Mode debug

# Production
npm run build              # Construire l'application
npm run start:prod         # Démarrer en production

# Base de données
npm run migration:run      # Exécuter les migrations
npm run migration:revert   # Revenir en arrière
npm run seed              # Peupler avec des données de test

# Docker
npm run docker:up         # Démarrer les services Docker
npm run docker:down       # Arrêter les services Docker
npm run docker:logs       # Voir les logs Docker

# Utilitaires
npm run reset-db          # Réinitialiser la base de données
npm run setup             # Configuration complète
npm run dev               # Environnement de développement complet
```

## 🧪 Tests

```bash
# Tests unitaires
npm run test

# Tests en mode watch
npm run test:watch

# Tests avec couverture
npm run test:cov

# Tests e2e
npm run test:e2e
```

## 🚀 Déploiement

### Variables d'environnement de production

```bash
NODE_ENV=production
PORT=3000

# Base de données
DB_HOST=your-mysql-host
DB_NAME=showme_prod
DB_USER=your-db-user
DB_PASSWORD=your-secure-password

# JWT (générer des clés fortes)
JWT_SECRET=your-super-secure-jwt-secret-min-32-chars
JWT_REFRESH_SECRET=your-super-secure-refresh-secret-min-32-chars

# Stripe
STRIPE_SECRET_KEY=sk_live_your_live_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Email
SMTP_HOST=your-smtp-provider
SMTP_USER=your-email-user
SMTP_PASS=your-email-password

# Stockage S3
AWS_S3_BUCKET=your-production-bucket
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
```

### Avec Docker

```bash
# Construire l'image
docker build -t showme-backend .

# Démarrer en production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🔒 Sécurité

### Mesures implémentées

- **Rate Limiting** - Protection contre les attaques DDoS
- **Helmet** - Headers de sécurité HTTP
- **CORS** - Configuration CORS stricte
- **JWT** - Authentification sécurisée avec refresh tokens
- **Bcrypt** - Hashage sécurisé des mots de passe
- **Validation** - Validation stricte des données entrantes
- **HTTPS** - Chiffrement des communications

### Recommandations production

1. **Générer des secrets JWT forts** (min 32 caractères)
2. **Configurer HTTPS** avec des certificats SSL valides
3. **Utiliser un WAF** (Web Application Firewall)
4. **Monitorer les logs** et configurer des alertes
5. **Sauvegarder régulièrement** la base de données
6. **Mettre à jour** les dépendances régulièrement

## 📈 Performance

### Optimisations incluses

- **Redis Cache** - Cache en mémoire pour les sessions
- **Compression Gzip** - Compression des réponses HTTP
- **Connection Pooling** - Pool de connexions MySQL
- **Pagination** - Pagination automatique des listes
- **Indexes** - Index de base de données optimisés

### Monitoring

- **Health Check** - Endpoint `/health` pour monitoring
- **Logs structurés** - Logs JSON pour analyse
- **Métriques** - Prêt pour Prometheus/Grafana

## 🛠️ Développement

### Structure des modules

Chaque module suit la structure NestJS standard :

```
module/
├── dto/                # Data Transfer Objects
├── entities/           # Entités TypeORM (si nécessaire)
├── guards/            # Guards personnalisés
├── services/          # Logique métier
├── controllers/       # Contrôleurs HTTP
└── module.ts          # Définition du module
```

### Bonnes pratiques

1. **Validation** - Utiliser les DTOs avec class-validator
2. **Transformations** - Utiliser class-transformer pour les réponses
3. **Documentation** - Documenter avec Swagger/OpenAPI
4. **Tests** - Écrire des tests unitaires et d'intégration
5. **Types** - Utiliser TypeScript strictement

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit les changements (`git commit -am 'Ajouter nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créer une Pull Request

## 📞 Support

- **Documentation**: `/api/docs`
- **Issues**: Utiliser GitHub Issues
- **Email**: support@showme.app

## 📝 Licence

Ce projet est sous licence propriétaire ShowMe Corp.

---

## 🔄 Changelog

### v1.0.0 (2024-07-04)
- ✨ Configuration initiale NestJS + TypeORM
- 🔐 Système d'authentification JWT complet
- 👤 Gestion des utilisateurs et profils
- 🃏 Module de cartes de contact
- 📊 Analytics de base
- 🐳 Configuration Docker complète
- 📚 Documentation Swagger
- 🔒 Mesures de sécurité de base