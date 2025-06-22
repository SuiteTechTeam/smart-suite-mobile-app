import 'package:flutter/foundation.dart';

/// Application configuration constants
///
/// This file contains all the global configuration values used throughout the app.
/// It centralizes important constants like API endpoints, versions, and other
/// configuration parameters.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // === API ENDPOINTS ===

  /// Smart Suite Web Service - Used for IAM authentication.
  /// This URL is dynamically set based on the build mode (debug/production).
  static String get smartSuiteBaseUrl {
    return 'https://smart-suite-web-service.azurewebsites.net';
  }

  /// API version used in all requests
  static const String apiVersion = 'api/v1';

  // === COMPUTED API URLS ===

  /// Smart Suite API base URL for all operations, combining base URL and API version.
  static String get smartSuiteApiBaseUrl => '$smartSuiteBaseUrl/$apiVersion';

  /// Legacy support - maintains backward compatibility
  @Deprecated('Use smartSuiteApiBaseUrl instead')
  static String get apiBaseUrl => smartSuiteApiBaseUrl;

  // === API SPECIFIC ENDPOINTS ===

  /// Authentication endpoints
  static String get authenticationUrl => '$smartSuiteApiBaseUrl/authentication';

  /// Hotel management endpoints
  static String get hotelApiUrl => '$smartSuiteApiBaseUrl/hotel';

  /// Room management endpoints
  static String get roomApiUrl => '$smartSuiteApiBaseUrl/rooms';

  /// Booking management endpoints
  static String get bookingApiUrl => '$smartSuiteApiBaseUrl/bookings';

  /// User management endpoints
  static String get userApiUrl => '$smartSuiteApiBaseUrl/user';

  /// Provider management endpoints
  static String get providerApiUrl => '$smartSuiteApiBaseUrl/provider';

  /// Supply management endpoints
  static String get supplyApiUrl => '$smartSuiteApiBaseUrl/supply';

  /// Customer management endpoints
  static String get customerApiUrl => '$smartSuiteApiBaseUrl/customer';

  /// Worker area management endpoints
  static String get workerAreaApiUrl => '$smartSuiteApiBaseUrl/worker-area';

  /// Assignment worker endpoints
  static String get assignmentWorkerApiUrl =>
      '$smartSuiteApiBaseUrl/assignment-worker';

  /// Reports endpoints
  static String get reportsApiUrl => '$smartSuiteApiBaseUrl/reports';

  // === APPLICATION INFO ===

  /// Application name
  static const String appName = 'Smart Suite';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Timeout for HTTP requests (in seconds)
  static const int httpTimeoutSeconds = 30;

  /// Environment configuration, dynamically set based on build mode.
  static String get environment => kDebugMode ? 'development' : 'production';

  /// Debug mode flag, reflects the current build mode.
  static const bool isDebugMode = kDebugMode;
}
