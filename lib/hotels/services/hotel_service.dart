import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../../iam/services/storage_service.dart';
import '../../core/config/app_config.dart';
import 'dart:io';

class HotelService {
  final String baseUrl = AppConfig.smartSuiteBaseUrl;
  final StorageService _storageService = StorageService();
  
  // HTTP client with timeout configuration
  static const Duration _defaultTimeout = Duration(seconds: 30);

  HotelService();

  // Helper function to get headers with the token
  Future<Map<String, String>> _getHeaders() async {
    return await _storageService.getAuthHeaders();
  }
  // Helper function for HTTP GET with timeout and better error handling
  Future<http.Response> _getWithTimeout(String url, Map<String, String> headers) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(_defaultTimeout);
      return response;
    } on SocketException catch (e) {
      throw Exception('Network error: Unable to connect to server. Please check your internet connection. Details: $e');
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout: Server took too long to respond. Please try again.');
      }
      // Don't wrap all exceptions as network errors - preserve original exceptions
      rethrow;
    }
  }
  // Helper function for HTTP POST with timeout and better error handling
  Future<http.Response> _postWithTimeout(String url, Map<String, String> headers, String body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(_defaultTimeout);
      return response;
    } on SocketException catch (e) {
      throw Exception('Network error: Unable to connect to server. Please check your internet connection. Details: $e');
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout: Server took too long to respond. Please try again.');
      }
      // Don't wrap all exceptions as network errors - preserve original exceptions
      rethrow;
    }
  }
  // Helper function for HTTP PUT with timeout and better error handling
  Future<http.Response> _putWithTimeout(String url, Map<String, String> headers, String body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(_defaultTimeout);
      return response;
    } on SocketException catch (e) {
      throw Exception('Network error: Unable to connect to server. Please check your internet connection. Details: $e');
    } on HttpException catch (e) {
      throw Exception('HTTP error: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout: Server took too long to respond. Please try again.');
      }
      // Don't wrap all exceptions as network errors - preserve original exceptions
      rethrow;
    }
  }

  // Get hotel information by ID
  Future<Hotel?> getHotelById(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await _getWithTimeout('$baseUrl/api/v1/hotels/$hotelId', headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Hotel not found
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load hotel: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Get hotel information by ID (returns Map for backwards compatibility)
  Future<Map<String, dynamic>?> getHotelByIdAsMap(int hotelId) async {
    try {
      final hotel = await getHotelById(hotelId);
      return hotel?.toJson();
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Get all hotels (for selection)
  Future<List<Hotel>> getAllHotels() async {
    try {
      final headers = await _getHeaders();
      final response = await _getWithTimeout('$baseUrl/api/v1/hotels', headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Get all hotels as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getAllHotelsAsMaps() async {
    try {
      final hotels = await getAllHotels();
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Get hotels by owner ID
  Future<List<Hotel>> getHotelsByOwnerId(int ownerId) async {
    try {
      final headers = await _getHeaders();
      final response = await _getWithTimeout('$baseUrl/api/v1/hotels/owner/$ownerId', headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load hotels by owner: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Get hotels by owner ID as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getHotelsByOwnerIdAsMaps(int ownerId) async {
    try {
      final hotels = await getHotelsByOwnerId(ownerId);
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }

  // Create a new hotel
  Future<Hotel> createHotel({
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    int? ownerId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': ownerId,
      });
      final response = await _postWithTimeout(
        '$baseUrl/api/v1/hotels',
        headers,
        body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. Only owners can create hotels.');
      } else {
        throw Exception('Failed to create hotel: {response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Create hotel returning Map (for backwards compatibility)
  Future<Map<String, dynamic>> createHotelAsMap({
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    int? ownerId,
  }) async {
    try {
      final hotel = await createHotel(
        name: name,
        address: address,
        phone: phone,
        email: email,
        description: description,
        ownerId: ownerId,
      );
      return hotel.toJson();
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Update hotel information
  Future<Hotel> updateHotel({
    required int hotelId,
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    int? ownerId,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': ownerId,
      });

      final response = await _putWithTimeout(
        '$baseUrl/api/v1/hotels/$hotelId',
        headers,
        body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. Only owners can update hotels.');
      } else {
        throw Exception('Failed to update hotel: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
  // Update hotel returning Map (for backwards compatibility)
  Future<Map<String, dynamic>> updateHotelAsMap({
    required int hotelId,
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    int? ownerId,
  }) async {
    try {
      final hotel = await updateHotel(
        hotelId: hotelId,
        name: name,
        address: address,
        phone: phone,
        email: email,
        description: description,
        ownerId: ownerId,
      );
      return hotel.toJson();
    } catch (e) {
      rethrow; // Re-throw with improved error message from helper methods
    }
  }
}