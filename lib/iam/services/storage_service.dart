import 'package:shared_preferences/shared_preferences.dart';
import '../models/authenticated_user.dart';
import 'dart:convert';

class StorageService {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'authenticated_user';

  Future<void> saveAuthenticatedUser(AuthenticatedUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, user.token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AuthenticatedUser?> getAuthenticatedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
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
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAuthenticatedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }
}
