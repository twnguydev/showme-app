#!/bin/bash
echo "📦 Build de production Showme"

# Build backend
echo "🔧 Build du backend..."
cd backend
npm run build
cd ..

# Build mobile
echo "📱 Build de l'app mobile..."
cd mobile

# Android
flutter build apk --release
echo "✅ APK généré: mobile/build/app/outputs/flutter-apk/app-release.apk"

# iOS (si sur macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release
    echo "✅ Build iOS terminé"
fi

cd ..
echo "✅ Build terminé!"