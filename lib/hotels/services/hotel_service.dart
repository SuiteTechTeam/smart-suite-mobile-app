import 'dart:convert';
import '../models/hotel.dart';
import '../../core/services/base_service.dart';
import '../../iam/services/auth_service.dart';
import '../utils/hotel_auth_validator.dart';

class HotelService extends BaseService {
  final AuthService _authService = AuthService();

  HotelService({super.httpClient});

  /// Validates if the current user is an owner
  Future<void> _validateOwnerAccess() async {
    await HotelAuthValidator.validateOwnerAccess();
  }

  /// Gets the authenticated user's ID, ensuring they are an owner
  Future<int> _getAuthenticatedOwnerId() async {
    return await HotelAuthValidator.getAuthenticatedOwnerId();
  }

  /// Validates if the current user can access a specific hotel
  Future<void> _validateHotelAccess(int hotelId) async {
    await HotelAuthValidator.validateHotelAccess(hotelId, (id) async {
      final hotel = await getHotelById(id);
      return hotel?.toJson();
    });
  }

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

  // Get all hotels (for selection) - restricted based on user role
  Future<List<Hotel>> getAllHotels() async {
    try {
      final userRole = await _authService.getUserRole();

      // If user is owner, only return their hotels
      if (userRole?.toLowerCase() == 'owner') {
        final userId = await _authService.getUserId();
        if (userId != null) {
          return await getHotelsByOwnerId(userId);
        }
      }

      // For admin and guest, or fallback
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

  // Get hotels by owner ID - with access validation
  Future<List<Hotel>> getHotelsByOwnerId(int ownerId) async {
    try {
      // Validate that the requesting user can access this owner's hotels
      await HotelAuthValidator.validateOwnerHotelsAccess(ownerId);

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
  Future<List<Map<String, dynamic>>> getHotelsByOwnerIdAsMaps(
    int ownerId,
  ) async {
    try {
      final hotels = await getHotelsByOwnerId(ownerId);
      return hotels.map((hotel) => hotel.toJson()).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create a new hotel - only for authenticated owners
  Future<Hotel> createHotel({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String description,
    int? ownerId, // This parameter is now ignored for security
  }) async {
    try {
      // Validate that the current user is an owner using HotelAuthValidator
      await HotelAuthValidator.validateOwnerAccess();
      // Get the authenticated user's ID and validate they are an owner
      final authenticatedOwnerId = await _getAuthenticatedOwnerId();
      // Always use the authenticated user's ID, ignore any passed ownerId
      final body = {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': authenticatedOwnerId, // Always use authenticated user's ID
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

  // Update hotel information - only for authenticated owners of the hotel
  Future<Hotel> updateHotel({
    required int hotelId,
    required String name,
    required String address,
    required String phone,
    required String email,
    String? description,
    int? ownerId, // This parameter is now ignored for security
  }) async {
    try {

      // Get the authenticated user's ID and validate they are an owner
      final authenticatedOwnerId = await _getAuthenticatedOwnerId();

      // Always use the authenticated user's ID, ignore any passed ownerId
      final body = {
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'description': description,
        'ownerId': authenticatedOwnerId, // Always use authenticated user's ID
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

  // Delete a hotel - only for authenticated owners of the hotel
  Future<bool> deleteHotel(int hotelId) async {
    try {
      // Validate access to this specific hotel
      await _validateHotelAccess(hotelId);

      // Ensure user is an owner
      await _validateOwnerAccess();

      final response = await authenticatedDelete('hotels/$hotelId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      // BaseService handles error codes automatically
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Get hotel statistics for owner dashboard
  Future<Map<String, dynamic>> getHotelStatistics(int hotelId) async {
    try {
      // Validate access to this specific hotel
      await _validateHotelAccess(hotelId);

      final response = await authenticatedGet('hotels/$hotelId/statistics');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Return empty stats if not available
      return {
        'totalRooms': 0,
        'occupiedRooms': 0,
        'occupancyRate': 0.0,
        'totalRevenue': 0.0,
        'monthlyRevenue': 0.0,
      };
    } catch (e) {
      // Return empty stats on error
      return {
        'totalRooms': 0,
        'occupiedRooms': 0,
        'occupancyRate': 0.0,
        'totalRevenue': 0.0,
        'monthlyRevenue': 0.0,
      };
    }
  }

  // Validate hotel exists and user has access to it
  Future<bool> validateHotelAccess(int hotelId) async {
    try {
      await _validateHotelAccess(hotelId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user's role for UI display purposes
  Future<String?> getCurrentUserRole() async {
    return await _authService.getUserRole();
  }

  // Get current user's ID
  Future<int?> getCurrentUserId() async {
    return await _authService.getUserId();
  } // Check if current user is an owner

  Future<bool> isCurrentUserOwner() async {
    return await HotelAuthValidator.isCurrentUserOwner();
  }

  // Get user's permissions for hotel operations
  Future<Map<String, bool>> getUserPermissions() async {
    return await HotelAuthValidator.getUserPermissions();
  }

  // // // BACKWARDS COMPATIBILITY METHODS // // //

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

  // Create hotel returning Map (for backwards compatibility)
  Future<Map<String, dynamic>> createHotelAsMap({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String description,
    int? ownerId, // This parameter is ignored for security
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
}
