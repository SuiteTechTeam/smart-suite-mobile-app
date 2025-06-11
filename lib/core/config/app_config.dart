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
  static const String smartSuiteBaseUrl = 'http://smart-suite-web-service.azurewebsites.net';
  
  /// Sweet Manager API - Used for business logic services
  static const String sweetManagerBaseUrl = 'https://sweetmanager-api.ryzeon.me';
  
  /// API version used in all requests
  static const String apiVersion = 'api/v1';
  
  // === COMPUTED API URLS ===
  
  /// Smart Suite API base URL for IAM operations
  static String get smartSuiteApiBaseUrl => '$smartSuiteBaseUrl/$apiVersion';
  
  /// Sweet Manager API base URL for business operations
  static String get sweetManagerApiBaseUrl => '$sweetManagerBaseUrl/$apiVersion';
  
  /// Legacy support - maintains backward compatibility
  @Deprecated('Use smartSuiteApiBaseUrl or sweetManagerApiBaseUrl instead')
  static String get apiBaseUrl => smartSuiteApiBaseUrl;
  
  // === API SPECIFIC ENDPOINTS ===
  
  /// Authentication endpoints
  static String get authenticationUrl => '$sweetManagerBaseUrl/$apiVersion/authentication';
  
  /// Hotel management endpoints
  static String get hotelApiUrl => '$sweetManagerBaseUrl/api/hotel';
  
  /// Room management endpoints
  static String get roomApiUrl => '$sweetManagerBaseUrl/api/rooms';
  
  /// Booking management endpoints
  static String get bookingApiUrl => '$sweetManagerBaseUrl/api/bookings';
  
  /// User management endpoints
  static String get userApiUrl => '$sweetManagerBaseUrl/$apiVersion/user';
  
  /// Provider management endpoints
  static String get providerApiUrl => '$sweetManagerBaseUrl/api/provider';
  
  /// Supply management endpoints
  static String get supplyApiUrl => '$sweetManagerBaseUrl/api/supply';
  
  /// Customer management endpoints
  static String get customerApiUrl => '$sweetManagerBaseUrl/api/customer';
  
  /// Worker area management endpoints
  static String get workerAreaApiUrl => '$sweetManagerBaseUrl/$apiVersion/worker-area';
  
  /// Assignment worker endpoints
  static String get assignmentWorkerApiUrl => '$sweetManagerBaseUrl/$apiVersion/assignment-worker';
  
  /// Reports endpoints
  static String get reportsApiUrl => '$sweetManagerBaseUrl/api';
  
  // === APPLICATION INFO ===
  
  /// Application name
  static const String appName = 'Smart Suite';
  
  /// Application version
  static const String appVersion = '1.0.0';
  
  /// Timeout for HTTP requests (in seconds)
  static const int httpTimeoutSeconds = 30;
  
  /// Environment configuration
  static const String environment = 'production'; // TODO: Make this configurable
  
  /// Debug mode flag
  static const bool isDebugMode = false; // TODO: Make this configurable based on build mode
}
