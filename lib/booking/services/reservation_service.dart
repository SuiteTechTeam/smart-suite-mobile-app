import 'dart:convert';
import '../models/reservation.dart';
import '../../core/services/base_service.dart';

class ReservationService extends BaseService {
  ReservationService({super.httpClient});

  // Helper method to safely parse JSON response that might be a List or Map
  Map<String, dynamic>? _parseJsonResponse(dynamic jsonData, String methodName) {
    try {
      if (jsonData is List) {
        print('Debug - $methodName: API returned List with ${jsonData.length} items');
        if (jsonData.isNotEmpty) {
          final firstItem = jsonData.first;
          if (firstItem is Map<String, dynamic>) {
            print('Debug - $methodName: Using first item from list');
            return firstItem;
          } else {
            print('Debug - $methodName: First item in list is not a Map: ${firstItem.runtimeType}');
            return null;
          }
        } else {
          print('Debug - $methodName: API returned empty list');
          return null;
        }
      } else if (jsonData is Map<String, dynamic>) {
        print('Debug - $methodName: API returned Map directly');
        return jsonData;
      } else {
        print('Debug - $methodName: Unexpected data type: ${jsonData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('Debug - $methodName: Error parsing JSON response: $e');
      return null;
    }
  }

  // Create a new reservation (booking)
  Future<bool> createReservation(Reservation reservation) async {
    try {
      print('Debug - createReservation: Sending reservation data: ${reservation.toJson()}');
      
      final response = await authenticatedPost(
        'booking/create-booking',
        body: reservation.toJson(),
      );

      print('Debug - createReservation: Response status: ${response.statusCode}');
      print('Debug - createReservation: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to create reservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - createReservation Error: $e');
      rethrow;
    }
  }

  // Create a new reservation and return the created reservation
  Future<Reservation> createReservationAndReturn(Reservation reservation) async {
    try {
      print('Debug - Sending reservation data: ${reservation.toJson()}');
      
      final response = await authenticatedPost(
        'booking/create-booking',
        body: reservation.toJson(),
      );

      print('Debug - API Response Status: ${response.statusCode}');
      print('Debug - API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If response body is empty or just a success message, return the original reservation
        if (response.body.isEmpty || response.body.trim() == 'true' || response.body.trim() == 'false') {
          print('Debug - API returned simple success response, returning original reservation');
          return reservation;
        }

        // Try to parse the response
        dynamic jsonData;
        try {
          jsonData = json.decode(response.body);
        } catch (parseError) {
          print('Debug - JSON Parse Error: $parseError');
          print('Debug - Response body that failed to parse: "${response.body}"');
          // If we can't parse JSON but got success status, return original reservation
          return reservation;
        }

        print('Debug - Parsed JSON Type: ${jsonData.runtimeType}');
        print('Debug - Parsed JSON Data: $jsonData');

        // Handle different response formats using helper method
        final reservationData = _parseJsonResponse(jsonData, 'createReservationAndReturn');
        
        if (reservationData == null) {
          print('Debug - createReservationAndReturn: Could not parse response, returning original reservation');
          return reservation;
        }

        try {
          return Reservation.fromJson(reservationData);
        } catch (parseError) {
          print('Debug - Reservation.fromJson Error: $parseError');
          print('Debug - Reservation Data: $reservationData');
          return reservation;
        }
      } else {
        print('Debug - API Error Status: ${response.statusCode}');
        print('Debug - API Error Body: ${response.body}');
        throw Exception(
          'Failed to create reservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - createReservationAndReturn Error: $e');
      if (e.toString().contains('type List<dynamic> is not a subtype of type Map<String, dynamic>')) {
        print('Debug - Detected List/Map type mismatch error');
        // Return the original reservation if we can't parse the response
        return reservation;
      }
      rethrow;
    }
  }

  // Get all reservations (bookings) for a hotel
  Future<List<Reservation>> getReservationsByHotelId(int hotelId) async {
    try {
      final response = await authenticatedGet(
        'booking/get-all-bookings?hotelId=$hotelId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load reservations: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservations (bookings) by customer
  Future<List<Reservation>> getReservationsByCustomerId(int customerId) async {
    try {
      final response = await authenticatedGet(
        'booking/get-booking-by-customer-id?customerId=$customerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load customer reservations: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservation (booking) by ID
  Future<Reservation?> getReservationById(int reservationId) async {
    try {
      final response = await authenticatedGet(
        'booking/get-booking-by-id?id=$reservationId',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle different response formats using helper method
        final reservationData = _parseJsonResponse(jsonData, 'getReservationById');
        
        if (reservationData == null) {
          print('Debug - getReservationById: Could not parse response');
          return null;
        }

        try {
          return Reservation.fromJson(reservationData);
        } catch (parseError) {
          print('Debug - getReservationById: Reservation.fromJson Error: $parseError');
          print('Debug - getReservationById: Reservation Data: $reservationData');
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load reservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - getReservationById Error: $e');
      rethrow;
    }
  }

  // Update reservation status
  Future<bool> updateReservationStatus(int reservationId, String state) async {
    try {
      final response = await authenticatedPut(
        'booking/update-booking-state',
        body: {'id': reservationId, 'state': state},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update reservation status: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Cancel reservation
  Future<bool> cancelReservation(int reservationId) async {
    try {
      return await updateReservationStatus(reservationId, 'cancelled');
    } catch (e) {
      rethrow;
    }
  }

  // Confirm reservation
  Future<bool> confirmReservation(int reservationId) async {
    try {
      return await updateReservationStatus(reservationId, 'confirmed');
    } catch (e) {
      rethrow;
    }
  }

  // Update reservation end date
  Future<bool> updateReservationEndDate(
    int reservationId,
    DateTime endDate,
  ) async {
    try {
      final response = await authenticatedPut(
        'booking/update-booking-end-date',
        body: {'id': reservationId, 'endDate': endDate.toIso8601String()},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
          'Failed to update reservation end date: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservations by hotel ID and state
  Future<List<Reservation>> getReservationsByHotelIdAndState(
    int hotelId,
    String state,
  ) async {
    try {
      final response = await authenticatedGet(
        'booking/get-booking-by-hotel-id-and-state?hotelId=$hotelId&state=$state',
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load reservations by hotel and state: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // NOTE: In Smart Suite, 'booking' and 'reservation' are the same concept.
  // All endpoints and models for 'booking' are handled as 'reservation' in the app.
  // The ReservationService and UI allow all roles (Owner, Admin, Guest) to create reservations.
  // The AddReservationScreen will now adapt the Customer ID field based on user role.
}
