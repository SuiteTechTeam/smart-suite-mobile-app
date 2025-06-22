import 'dart:convert';
import 'dart:io'; // For SocketException, HttpException
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../iam/services/auth_service.dart';
import '../../iam/services/storage_service.dart';
import '../config/app_config.dart';

/// Base service class that handles JWT authentication and HTTP operations
/// All other services should extend this class to ensure consistent auth handling
abstract class BaseService {
  final StorageService _storageService = StorageService();
  final http.Client _httpClient;

  // Default timeout for HTTP requests
  static const Duration _defaultTimeout = Duration(seconds: 30);

  BaseService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Get authenticated headers with JWT token
  Future<Map<String, String>> getAuthHeaders() async {
    try {
      final token = await _storageService.getToken();

      if (token == null || token.isEmpty) {
        throw AuthenticationException(
          'No authentication token found. Please login again.',
        );
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        // Clear expired token
        await _storageService.clearAuthenticatedUser();
        throw AuthenticationException(
          'Authentication token has expired. Please login again.',
        );
      }

      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      if (e is AuthenticationException) {
        rethrow;
      }
      throw AuthenticationException('Error accessing authentication token: $e');
    }
  }

  /// Get basic headers without authentication (for public endpoints)
  Map<String, String> getBasicHeaders() {
    return {'Content-Type': 'application/json'};
  }

  /// Build full URL for API endpoints
  String buildUrl(String endpoint) {
    final baseUrl = AppConfig.smartSuiteBaseUrl;
    final apiVersion = AppConfig.apiVersion;

    // Remove leading slash if present to avoid double slashes
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;

    return '$baseUrl/$apiVersion/$cleanEndpoint';
  }

  /// Execute GET request with authentication
  Future<http.Response> authenticatedGet(String endpoint) async {
    return await _executeWithTimeout(() async {
      final headers = await getAuthHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.get(Uri.parse(url), headers: headers);
    });
  }

  /// Execute POST request with authentication
  Future<http.Response> authenticatedPost(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return await _executeWithTimeout(() async {
      final headers = await getAuthHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Execute PUT request with authentication
  Future<http.Response> authenticatedPut(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return await _executeWithTimeout(() async {
      final headers = await getAuthHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Execute DELETE request with authentication
  Future<http.Response> authenticatedDelete(String endpoint) async {
    return await _executeWithTimeout(() async {
      final headers = await getAuthHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.delete(Uri.parse(url), headers: headers);
    });
  }

  /// Execute public GET request (no authentication required)
  Future<http.Response> publicGet(String endpoint) async {
    return await _executeWithTimeout(() async {
      final headers = getBasicHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.get(Uri.parse(url), headers: headers);
    });
  }

  /// Execute public POST request (no authentication required)
  Future<http.Response> publicPost(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    return await _executeWithTimeout(() async {
      final headers = getBasicHeaders();
      final url = buildUrl(endpoint);

      return await _httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
    });
  }

  /// Execute HTTP request with timeout and error handling
  Future<http.Response> _executeWithTimeout(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(_defaultTimeout);

      // Handle common HTTP status codes
      _handleResponseErrors(response);

      return response;
    } on SocketException catch (e) {
      throw NetworkException(
        'Unable to connect to server. Please check your internet connection. Details: $e',
      );
    } on HttpException catch (e) {
      throw NetworkException('HTTP error encountered: $e');
    } on FormatException catch (e) {
      throw NetworkException('Invalid response format: $e');
    } on TimeoutException {
      throw NetworkException(
        'Request timeout: Server took too long to respond. Please try again.',
      );
    } catch (e) {
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  /// Handle common HTTP response errors
  void _handleResponseErrors(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw AuthenticationException(
          'Unauthorized access. Please login again.',
        );
      case 403:
        throw AuthenticationException(
          'Access forbidden. You don\'t have permission to perform this action.',
        );
      case 404:
        throw NotFoundException('Resource not found.');
      case 422:
        throw ValidationException('Invalid data provided: ${response.body}');
      case 500:
        throw ServerException('Internal server error. Please try again later.');
      case 502:
      case 503:
      case 504:
        throw ServerException(
          'Server temporarily unavailable. Please try again later.',
        );
    }
  }

  /// Get user information from JWT token
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final token = await _storageService.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decodedToken = JwtDecoder.decode(token);

        // Usar los nombres completos de los claims de JWT
        final String sidClaim = AuthService.sidClaimKey;
        final String roleClaim = AuthService.roleClaimKey;
        final String localityClaim = AuthService.localityClaimKey;
        final String emailClaim = AuthService.emailClaimKey;
        final String emailSimple = AuthService.emailSimpleKey;
        final String userIdSimple = AuthService.userIdSimpleKey;

        // Intentar obtener datos desde claims completos primero, luego desde versiones simplificadas
        final sid =
            decodedToken[sidClaim] ??
            decodedToken[userIdSimple] ??
            decodedToken['sid'];
        final roleString = decodedToken[roleClaim] ?? decodedToken['role'];
        final locality =
            decodedToken[localityClaim] ?? decodedToken['locality'];
        final email =
            decodedToken[emailClaim] ??
            decodedToken[emailSimple] ??
            decodedToken['email'];

        int? roleId;
        if (roleString != null) {
          // Extraer el nombre del rol, quitando el prefijo 'ROLE_' si existe
          String roleName = roleString.toString();
          if (roleName.startsWith('ROLE_')) {
            roleName = roleName.substring(5).toLowerCase();
          } else {
            roleName = roleName.toLowerCase();
          }

          switch (roleName) {
            case 'owner':
              roleId = 1;
              break;
            case 'admin':
              roleId = 2;
              break;
            case 'guest':
              roleId = 3;
              break;
            default:
              roleId = null;
          }
        }

        return {
          'id': sid != null ? int.tryParse(sid.toString()) : null,
          'email': email?.toString(),
          'role': roleString?.toString(),
          'roleId': roleId,
          'hotelId': locality != null && locality.toString().isNotEmpty
              ? int.tryParse(locality.toString())
              : null,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user ID from JWT token
  Future<int?> getUserId() async {
    final userInfo = await getUserInfo();
    return userInfo?['id'];
  }

  /// Get user role from JWT token
  Future<String?> getUserRole() async {
    final userInfo = await getUserInfo();
    return userInfo?['role'];
  }

  /// Get hotel ID from JWT token
  Future<int?> getHotelIdFromToken() async {
    final userInfo = await getUserInfo();
    return userInfo?['hotelId'];
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _storageService.isAuthenticated();
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

/// Custom exceptions for better error handling
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

class AccessDeniedException implements Exception {
  final String message;
  AccessDeniedException(this.message);

  @override
  String toString() => 'AccessDeniedException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
