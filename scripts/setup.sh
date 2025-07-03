#!/bin/bash
# scripts/setup.sh

echo "🚀 Configuration initiale du projet Showme"

# Vérification des prérequis
command -v node >/dev/null 2>&1 || { echo "Node.js requis mais non installé."; exit 1; }
command -v flutter >/dev/null 2>&1 || { echo "Flutter requis mais non installé."; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "Docker requis mais non installé."; exit 1; }

# Configuration du backend
echo "📦 Configuration du backend..."
cd backend
cp .env.example .env
npm install

# Configuration mobile
echo "📱 Configuration mobile..."
cd ../mobile
flutter pub get
flutter pub run build_runner build

# Configuration Docker
echo "🐳 Démarrage des services Docker..."
cd ..
docker-compose up -d postgres redis

echo "✅ Projet configuré avec succès!"
echo ""
echo "🔗 URLs importantes:"
echo "- API Backend: http://localhost:1337"
echo "- Admin Panel: http://localhost:1337/admin"
echo "- PostgreSQL: localhost:5432"
echo ""
echo "📝 Prochaines étapes:"
echo "1. Configurer les variables d'environnement dans backend/.env"
echo "2. Lancer: cd backend && npm run develop"
echo "3. Créer un compte admin sur http://localhost:1337/admin"
echo "4. Lancer l'app mobile: cd mobile && flutter run"