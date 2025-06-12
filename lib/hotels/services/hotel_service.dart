import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../../iam/services/storage_service.dart';
import '../../core/config/app_config.dart';

class HotelService {
  final String baseUrl = AppConfig.smartSuiteBaseUrl;
  final StorageService _storageService = StorageService();

  HotelService();

  // Helper function to get headers with the token
  Future<Map<String, String>> _getHeaders() async {
    return await _storageService.getAuthHeaders();
  }

  // Get hotel information by ID
  Future<Hotel?> getHotelById(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Hotel not found
      } else {
        throw Exception('Failed to load hotel: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get hotel information by ID (returns Map for backwards compatibility)
  Future<Map<String, dynamic>?> getHotelByIdAsMap(int hotelId) async {
    try {
      final hotel = await getHotelById(hotelId);
      return hotel?.toJson();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all hotels (for selection)
  Future<List<Hotel>> getAllHotels() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hotels: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get all hotels as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getAllHotelsAsMaps() async {
    try {
      final hotels = await getAllHotels();
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get hotels by owner ID
  Future<List<Hotel>> getHotelsByOwnerId(int ownerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels/owner/$ownerId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hotels by owner: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get hotels by owner ID as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getHotelsByOwnerIdAsMaps(int ownerId) async {
    try {
      final hotels = await getHotelsByOwnerId(ownerId);
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create a new hotel
  Future<Hotel> createHotel({
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    String? website,
    int? ownerId,
    int? totalRooms,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'website': website,
        'ownerId': ownerId,
        'totalRooms': totalRooms,
        'amenities': amenities,
        'imageUrl': imageUrl,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/hotels'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else {
        throw Exception('Failed to create hotel: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Create hotel returning Map (for backwards compatibility)
  Future<Map<String, dynamic>> createHotelAsMap({
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    String? website,
    int? ownerId,
    int? totalRooms,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final hotel = await createHotel(
        name: name,
        address: address,
        phone: phone,
        email: email,
        description: description,
        website: website,
        ownerId: ownerId,
        totalRooms: totalRooms,
        amenities: amenities,
        imageUrl: imageUrl,
      );
      return hotel.toJson();
    } catch (e) {
      throw Exception('Network error: $e');
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
    String? website,
    int? totalRooms,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'website': website,
        'totalRooms': totalRooms,
        'amenities': amenities,
        'imageUrl': imageUrl,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else {
        throw Exception('Failed to update hotel: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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
    String? website,
    int? totalRooms,
    List<String>? amenities,
    String? imageUrl,
  }) async {
    try {
      final hotel = await updateHotel(
        hotelId: hotelId,
        name: name,
        address: address,
        phone: phone,
        email: email,
        description: description,
        website: website,
        totalRooms: totalRooms,
        amenities: amenities,
        imageUrl: imageUrl,
      );
      return hotel.toJson();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Delete hotel
  Future<bool> deleteHotel(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete hotel: ${response.statusCode} - ${response.body}');
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

  // Get hotel statistics
  Future<Map<String, dynamic>> getHotelStats(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/hotels/$hotelId/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load hotel stats: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Search hotels
  Future<List<Hotel>> searchHotels({
    String? query,
    String? city,
    double? minRating,
    double? maxRating,
    List<String>? amenities,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Build query parameters
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (maxRating != null) queryParams['maxRating'] = maxRating.toString();
      if (amenities != null && amenities.isNotEmpty) {
        queryParams['amenities'] = amenities.join(',');
      }

      final uri = Uri.parse('$baseUrl/api/v1/hotels/search').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search hotels: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
