import 'dart:convert';
import '../models/reservation.dart';
import '../../core/services/base_service.dart';

class ReservationService extends BaseService {
  ReservationService({super.httpClient});

  // Create a new reservation (booking)
  Future<bool> createReservation(Reservation reservation) async {
    try {
      final response = await authenticatedPost(
        'booking/create-booking',
        body: reservation.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to create reservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
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
        return Reservation.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to load reservation: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
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
