cd mobile

# Corriger le Podfile
sed -i '' "s/platform :ios, '[0-9]*\.[0-9]*'/platform :ios, '14.0'/" ios/Podfile

# Corriger le projet Xcode
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = [0-9]*\.[0-9]*;/IPHONEOS_DEPLOYMENT_TARGET = 14.0;/g' ios/Runner.xcodeproj/project.pbxproj

# Nettoyer les pods existants
cd ios
rm -rf Pods
rm Podfile.lock
cd ..

# Relancer
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run