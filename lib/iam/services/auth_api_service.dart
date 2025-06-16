import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../models/authenticated_user.dart';
import '../../core/config/app_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class AuthApiService {
  // Use centralized configuration instead of hardcoded URL
  static String get baseUrl => AppConfig.smartSuiteBaseUrl;
  static String get apiVersion => AppConfig.apiVersion;

  final http.Client _httpClient;

  AuthApiService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? _createHttpClient();
      
  // Create a more robust HTTP client
  static http.Client _createHttpClient() {
    final client = http.Client();
    // Add any additional configuration if needed
    return client;
  }Future<AuthenticatedUser> signIn(SignInRequest request) async {
    debugPrint('AuthApiService: baseUrl = $baseUrl');
    debugPrint('AuthApiService: apiVersion = $apiVersion');
    
    String finalUrl = '$baseUrl/$apiVersion/authentication/sign-in';
    debugPrint('AuthApiService: Initial URL = $finalUrl');
    debugPrint('AuthApiService: Expected URL = https://smart-suite-web-service.azurewebsites.net/api/v1/authentication/sign-in');
    debugPrint('AuthApiService: Request body: ${jsonEncode(request.toJson())}');
      // Test connectivity first
    debugPrint('AuthApiService: Testing connectivity before sign-in...');
    final isConnected = await testConnectivity();
    if (!isConnected) {
      throw ApiException('Unable to reach the server. Please check your internet connection and try again.');
    }
    debugPrint('AuthApiService: Connectivity test passed, proceeding with sign-in...');
    
    try {      debugPrint('AuthApiService: Making HTTP POST request...');      final response = await _httpClient.post(
        Uri.parse(finalUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      debugPrint('AuthApiService: Response status code: ${response.statusCode}');
      debugPrint('AuthApiService: Response headers: ${response.headers}');
      debugPrint('AuthApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final user = AuthenticatedUser.fromJson(jsonData);
        debugPrint('AuthApiService: Successfully parsed user: ${user.email}');
        return user;
      } else {
        debugPrint('AuthApiService: Failed with status ${response.statusCode}');
        throw ApiException(
          'Failed to sign in: HTTP ${response.statusCode} - ${response.body}',
          statusCode: response.statusCode,
        );
      }    } on SocketException catch (e) {
      debugPrint('AuthApiService: Socket exception (network issue): $e');
      throw ApiException('Network connection failed: ${e.message}. Please check your internet connection.');
    } on TimeoutException catch (e) {
      debugPrint('AuthApiService: Timeout exception: $e');
      throw ApiException('Request timed out. The server might be slow or unreachable.');
    } on FormatException catch (e) {
      debugPrint('AuthApiService: Format exception (JSON parsing): $e');
      throw ApiException('Invalid response format from server: $e');
    } catch (e) {
      debugPrint('AuthApiService: Unexpected exception during sign-in: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  // Alternative method using direct IP if DNS fails
  Future<AuthenticatedUser> signInWithFallback(SignInRequest request) async {
    try {
      // Try normal sign-in first
      return await signIn(request);
    } catch (e) {
      debugPrint('AuthApiService: Primary sign-in failed, trying fallback methods...');
      
      // Try with different timeout settings
      try {
        debugPrint('AuthApiService: Attempting with longer timeout...');
        
        final response = await _httpClient.post(
          Uri.parse('$baseUrl/$apiVersion/authentication/sign-in'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': '*/*',
            'User-Agent': 'Smart-Suite-Mobile-App/1.0',
            'Connection': 'keep-alive',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 60)); // Longer timeout
        
        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          return AuthenticatedUser.fromJson(jsonData);
        } else {
          throw ApiException('Sign-in failed with status ${response.statusCode}: ${response.body}');
        }
      } catch (fallbackError) {
        debugPrint('AuthApiService: Fallback also failed: $fallbackError');
        throw ApiException('All sign-in attempts failed. Original error: $e, Fallback error: $fallbackError');
      }
    }
  }

  // Method to test connectivity before attempting sign-in
  Future<bool> testConnectivity() async {
    try {
      debugPrint('AuthApiService: Testing connectivity to $baseUrl...');
      
      // Try DNS resolution first
      final addresses = await InternetAddress.lookup('smart-suite-web-service.azurewebsites.net')
          .timeout(const Duration(seconds: 10));
      debugPrint('AuthApiService: DNS resolved successfully: ${addresses.map((addr) => addr.address).join(', ')}');
      
      // Try a simple GET request to check if server is reachable
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/$apiVersion/'),
        headers: {
          'Accept': '*/*',
          'User-Agent': 'Smart-Suite-Mobile-App/1.0',
        },
      ).timeout(const Duration(seconds: 15));
      
      debugPrint('AuthApiService: Connectivity test response: ${response.statusCode}');
      return response.statusCode < 500; // Accept any response except server errors
      
    } catch (e) {
      debugPrint('AuthApiService: Connectivity test failed: $e');
      return false;
    }
  }

  Future<void> signUpAdmin(SignUpRequest request) async {
    await _signUp(request, 'sign-up-admin');
  }

  Future<void> signUpGuest(SignUpRequest request) async {
    await _signUp(request, 'sign-up-guest');
  }

  Future<void> signUpOwner(SignUpRequest request) async {
    await _signUp(request, 'sign-up-owner');
  }
  Future<void> _signUp(SignUpRequest request, String endpoint) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/$apiVersion/authentication/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          'Failed to sign up: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
