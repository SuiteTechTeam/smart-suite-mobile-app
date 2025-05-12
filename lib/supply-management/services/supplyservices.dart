import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SupplyService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  SupplyService();

  // Helper function to get the headers with the token
  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    if (token == null || JwtDecoder.isExpired(token)) {
      throw Exception('Token is missing or expired. Please log in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // POST /api/supply/create-supply
  Future<dynamic> createSupply(Map<String, dynamic> supply) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/supply/create-supply'),
      headers: headers,
      body: json.encode(supply),
    );

    print('POST /api/supply/create-supply response status: ${response.statusCode}');
    print('POST /api/supply/create-supply response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('Failed to create supply: ${response.statusCode} - ${response.body}');
    }
  }

  // PUT /api/supply/{id}
  Future<dynamic> updateSupply(int id, Map<String, dynamic> supply) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/supply/$id'),
      headers: headers,
      body: json.encode(supply),
    );

    print('PUT /api/supply/$id response status: ${response.statusCode}');
    print('PUT /api/supply/$id response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('Failed to update supply: ${response.statusCode} - ${response.body}');
    }
  }

  // GET /api/supply/{id}
  Future<dynamic> getSupplyById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/supply/$id'),
      headers: headers,
    );

    print('GET /api/supply/$id response status: ${response.statusCode}');
    print('GET /api/supply/$id response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supply: ${response.statusCode} - ${response.body}');
    }
  }

  // DELETE /api/supply/delete-supply
  Future<void> deleteSupply(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/supply/delete-supply?id=$id'),
      headers: headers,
    );

    print('DELETE /api/supply/delete-supply response status: ${response.statusCode}');
    print('DELETE /api/supply/delete-supply response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete supply: ${response.statusCode} - ${response.body}');
    }
  }

  // GET /api/supply/get-all-supplies
  Future<List<dynamic>> getSuppliesByHotelId(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/supply/get-all-supplies?hotelId=$hotelId'),
      headers: headers,
    );

    print('GET /api/supply/get-all-supplies response status: ${response.statusCode}');
    print('GET /api/supply/get-all-supplies response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supplies by Hotel ID: ${response.statusCode} - ${response.body}');
    }
  }

  // GET /api/supply/provider/{providerId}
  Future<List<dynamic>> getSuppliesByProviderId(int providerId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/supply/provider/$providerId'),
      headers: headers,
    );

    print('GET /api/supply/provider/$providerId response status: ${response.statusCode}');
    print('GET /api/supply/provider/$providerId response body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load supplies by Provider ID: ${response.statusCode} - ${response.body}');
    }
  }
}
