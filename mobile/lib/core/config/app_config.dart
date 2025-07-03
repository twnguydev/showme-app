// mobile/lib/core/config/app_config.dart
class AppConfig {
  static const String appName = 'Showme';
  static const String version = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'http://localhost:1337';
  static const String apiPath = '/api';
  static const String apiUrl = '$baseUrl$apiPath';
  
  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key';
  
  // NFC Configuration
  static const Duration nfcTimeout = Duration(seconds: 10);
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx'];
  
  // Features
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  
  // Development
  static const bool isDebugMode = true;
}