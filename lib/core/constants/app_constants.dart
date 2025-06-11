/// Core constants used throughout the application
/// 
/// This file contains various constants like error messages, default values,
/// and other application-wide constants.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();
  
  /// Storage keys for SharedPreferences
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  /// Error messages
  static const String genericErrorMessage = 'Algo salió mal. Por favor, inténtalo de nuevo.';
  static const String networkErrorMessage = 'Error de conexión. Verifica tu conexión a internet.';
  static const String unauthorizedErrorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
  static const String validationErrorMessage = 'Por favor, verifica los datos ingresados.';
  
  /// HTTP status codes
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpInternalServerError = 500;
  
  /// Default values
  static const int defaultPageSize = 20;
  static const int maxRetryAttempts = 3;
  
  /// Animation durations (in milliseconds)
  static const int shortAnimationDuration = 200;
  static const int mediumAnimationDuration = 500;
  static const int longAnimationDuration = 1000;
}
