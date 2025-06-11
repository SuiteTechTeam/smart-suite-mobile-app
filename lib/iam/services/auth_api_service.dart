import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../models/authenticated_user.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

class AuthApiService {
  static const String baseUrl = 'http://smart-suite-web-service.azurewebsites.net';
  static const String apiVersion = 'api/v1';

  final http.Client _httpClient;

  AuthApiService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  Future<AuthenticatedUser> signIn(SignInRequest request) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/$apiVersion/authentication/sign-in'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AuthenticatedUser.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to sign in: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
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
      );

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
