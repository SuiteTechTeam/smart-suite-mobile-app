import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../../core/services/base_service.dart';

class HotelService extends BaseService {

  HotelService({http.Client? httpClient}) : super(httpClient: httpClient);

  // Get hotel information by ID
  Future<Hotel?> getHotelById(int hotelId) async {
    try {
      final response = await authenticatedGet('hotels/$hotelId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // Hotel not found
      }
      
      // BaseService handles other error codes automatically
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get hotel information by ID (returns Map for backwards compatibility)
  Future<Map<String, dynamic>?> getHotelByIdAsMap(int hotelId) async {
    try {
      final hotel = await getHotelById(hotelId);
      return hotel?.toJson();
    } catch (e) {
      rethrow;
    }
  }

  // Get all hotels (for selection)
  Future<List<Hotel>> getAllHotels() async {
    try {
      final response = await authenticatedGet('hotels');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      }
      
      // BaseService handles error codes automatically
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get all hotels as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getAllHotelsAsMaps() async {
    try {
      final hotels = await getAllHotels();
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get hotels by owner ID
  Future<List<Hotel>> getHotelsByOwnerId(int ownerId) async {
    try {
      final response = await authenticatedGet('hotels/owner/$ownerId');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Hotel.fromJson(json)).toList();
      }
      
      // BaseService handles error codes automatically
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get hotels by owner ID as Maps (for backwards compatibility)
  Future<List<Map<String, dynamic>>> getHotelsByOwnerIdAsMaps(int ownerId) async {
    try {
      final hotels = await getHotelsByOwnerId(ownerId);
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      rethrow;
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
      final body = {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': ownerId,
      };

      final response = await authenticatedPost('hotels', body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      }
      
      // BaseService handles error codes automatically
      throw Exception('Failed to create hotel');
    } catch (e) {
      rethrow;
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
      rethrow;
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
      final body = {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': ownerId,
      };

      final response = await authenticatedPut('hotels/$hotelId', body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Hotel.fromJson(data);
      }
      
      // BaseService handles error codes automatically
      throw Exception('Failed to update hotel');
    } catch (e) {
      rethrow;
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
      rethrow;
    }
  }
}