# Showme - Application de cartes de visite digitales

## 📱 Description
Application mobile pour professionnels permettant le partage de cartes de visite interactives via NFC, QR code, et intégration Wallet.

## 🏗️ Architecture
- **Frontend**: Flutter (iOS/Android)
- **Backend**: Strapi CMS + PostgreSQL
- **Paiements**: Stripe + Tap to Pay
- **Fichiers**: DigitalOcean Spaces
- **Déploiement**: Docker + VPS

## 🔧 Installation rapide

### Prérequis
- Node.js 18+
- Flutter 3.16+
- Docker & Docker Compose
- PostgreSQL 15+

### Backend (Strapi)
```bash
cd backend
npm install
cp .env.example .env
# Configurer les variables dans .env
npm run develop
```

### Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

### Avec Docker
```bash
docker-compose up -d
```

## 🌐 URLs

API: http://localhost:1337
Admin: http://localhost:1337/admin
Mobile: Émulateur ou device physique

## 📚 Documentation

- API Documentation
- Mobile Documentation
- Deployment Guide

## 🔒 Sécurité

- JWT Authentication
- CORS configuré
- Validation des données
- Chiffrement des communications

## 📄 Licence
MIT License