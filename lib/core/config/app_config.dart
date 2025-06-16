/// Application configuration constants
///
/// This file contains all the global configuration values used throughout the app.
/// It centralizes important constants like API endpoints, versions, and other
/// configuration parameters.
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // === API ENDPOINTS ===

  /// Smart Suite Web Service - Used for IAM authentication
  static const String smartSuiteBaseUrl =
      'https://smart-suite-web-service.azurewebsites.net';

  /// API version used in all requests
  static const String apiVersion = 'api/v1';

  // === COMPUTED API URLS ===

  /// Smart Suite API base URL for IAM operations
  static String get smartSuiteApiBaseUrl => '$smartSuiteBaseUrl/$apiVersion';

  /// Legacy support - maintains backward compatibility
  @Deprecated('Use smartSuiteApiBaseUrl instead')
  static String get apiBaseUrl => smartSuiteApiBaseUrl;

  // === API SPECIFIC ENDPOINTS ===

  /// Authentication endpoints
  static String get authenticationUrl =>
      '$smartSuiteBaseUrl/$apiVersion/authentication';

  /// Hotel management endpoints
  static String get hotelApiUrl => '$smartSuiteBaseUrl/$apiVersion/hotel';

  /// Room management endpoints
  static String get roomApiUrl => '$smartSuiteBaseUrl/$apiVersion/rooms';

  /// Booking management endpoints
  static String get bookingApiUrl => '$smartSuiteBaseUrl/$apiVersion/bookings';

  /// User management endpoints
  static String get userApiUrl => '$smartSuiteBaseUrl/$apiVersion/user';

  /// Provider management endpoints
  static String get providerApiUrl => '$smartSuiteBaseUrl/$apiVersion/provider';

  /// Supply management endpoints
  static String get supplyApiUrl => '$smartSuiteBaseUrl/$apiVersion/supply';

  /// Customer management endpoints
  static String get customerApiUrl => '$smartSuiteBaseUrl/$apiVersion/customer';

  /// Worker area management endpoints
  static String get workerAreaApiUrl =>
      '$smartSuiteBaseUrl/$apiVersion/worker-area';

  /// Assignment worker endpoints
  static String get assignmentWorkerApiUrl =>
      '$smartSuiteBaseUrl/$apiVersion/assignment-worker';

  /// Reports endpoints
  static String get reportsApiUrl => '$smartSuiteBaseUrl/$apiVersion/reports';

  // === APPLICATION INFO ===

  /// Application name
  static const String appName = 'Smart Suite';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Timeout for HTTP requests (in seconds)
  static const int httpTimeoutSeconds = 30;

  /// Environment configuration
  static const String environment =
      'production'; // TODO: Make this configurable

  /// Debug mode flag
  static const bool isDebugMode =
      false; // TODO: Make this configurable based on build mode
}
