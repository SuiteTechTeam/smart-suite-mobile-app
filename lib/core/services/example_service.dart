import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/core.dart';

/// Example service demonstrating how to use the centralized AppConfig
/// 
/// This service shows the proper way to consume API endpoints from the
/// centralized configuration instead of hardcoding URLs.
class ExampleService {
  ExampleService();

  /// Helper function to get headers with the token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please log in again.');
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Example method using Sweet Manager API for hotel operations
  Future<List<dynamic>> getHotels() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.hotelApiUrl}/all'),
      headers: headers,
    );

    if (response.statusCode == AppConstants.httpOk) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load hotels: ${response.statusCode}');
    }
  }

  /// Example method using Sweet Manager API for user operations
  Future<int> getUserCount(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConfig.userApiUrl}/get-worker-count?hotelId=$hotelId'),
      headers: headers,
    );

    if (response.statusCode == AppConstants.httpOk) {
      final jsonData = jsonDecode(response.body);
      return jsonData['count'] ?? 0;
    } else {
      throw Exception('Failed to get user count: ${response.statusCode}');
    }
  }

  /// Example method using Smart Suite API for authentication
  Future<bool> authenticateUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConfig.smartSuiteApiBaseUrl}/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == AppConstants.httpOk) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, data['token']);
      return true;
    }
    return false;
  }

  /// Example method for creating resources
  Future<dynamic> createResource(Map<String, dynamic> resourceData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConfig.sweetManagerApiBaseUrl}/resource/create'),
      headers: headers,
      body: jsonEncode(resourceData),
    );

    if (response.statusCode == AppConstants.httpCreated || 
        response.statusCode == AppConstants.httpOk) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } else {
      throw Exception('Failed to create resource: ${response.statusCode}');
    }
  }
}
