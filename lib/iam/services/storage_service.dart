import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/authenticated_user.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'authenticated_user';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveAuthenticatedUser(AuthenticatedUser user) async {
    await _storage.write(key: _tokenKey, value: user.token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      return null;
    }
  }
  Future<AuthenticatedUser?> getAuthenticatedUser() async {
    try {
      final userJson = await _storage.read(key: _userKey)
          .timeout(const Duration(seconds: 5));
      
      if (userJson != null) {
        try {
          final userData = jsonDecode(userJson);
          return AuthenticatedUser.fromJson(userData);
        } catch (e) {
          // If there's an error parsing, clear the stored data
          await clearAuthenticatedUser();
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }  Future<bool> isAuthenticated() async {
    debugPrint('StorageService: Checking authentication status...');
    try {
      final token = await getToken();
      debugPrint('StorageService: Token retrieved: ${token != null ? 'exists' : 'null'}');
      
      if (token != null && token.isNotEmpty) {
        try {
          final isExpired = JwtDecoder.isExpired(token);
          debugPrint('StorageService: Token expired: $isExpired');
          return !isExpired;
        } catch (e) {
          debugPrint('StorageService: Error checking token expiration: $e');
          return false;
        }
      }
      debugPrint('StorageService: No valid token found');
      return false;
    } catch (e) {
      debugPrint('StorageService: Error in isAuthenticated: $e');
      return false;
    }
  }

  Future<void> clearAuthenticatedUser() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: 'selected_hotel_id');
  }  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    
    if (token != null && token.isNotEmpty) {
      try {
        // Check if token is not expired
        if (!JwtDecoder.isExpired(token)) {
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          };
        }
      } catch (e) {
        // Token is invalid, return headers without authorization
      }
    }
    
    return {
      'Content-Type': 'application/json',
    };
  }

  // Generic write method for additional storage needs
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Generic read method for additional storage needs
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Generic delete method for additional storage needs
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }
}
