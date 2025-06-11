import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class HotelService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  HotelService();

  // Helper function to get headers with the token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get hotel information by ID
  Future<Map<String, dynamic>?> getHotelById(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return null; // Hotel not found
      } else {
        throw Exception('Failed to load hotel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all hotels (for selection)
  Future<List<Map<String, dynamic>>> getAllHotels() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get hotels by owner ID
  Future<List<Map<String, dynamic>>> getHotelsByOwnerId(int ownerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels/owner/$ownerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load hotels by owner: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create a new hotel
  Future<Map<String, dynamic>> createHotel({
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/hotels'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create hotel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update hotel information
  Future<Map<String, dynamic>> updateHotel({
    required int hotelId,
    required String name,
    required String address,
    required String phone,
    required String email,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update hotel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Validate if a hotel ID exists
  Future<bool> validateHotelId(int hotelId) async {
    try {
      final hotel = await getHotelById(hotelId);
      return hotel != null;
    } catch (e) {
      return false;
    }
  }
}
