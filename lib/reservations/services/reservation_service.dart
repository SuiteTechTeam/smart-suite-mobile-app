import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import '../models/reservation_resource.dart';
import '../../core/services/base_service.dart';

class ReservationService extends BaseService {

  ReservationService({http.Client? httpClient}) : super(httpClient: httpClient);

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
        throw Exception('Failed to create reservation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all reservations (bookings) for a hotel
  Future<List<Reservation>> getReservationsByHotelId(int hotelId) async {
    try {
      final response = await authenticatedGet('booking/get-all-bookings?hotelId=$hotelId');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservations (bookings) by customer
  Future<List<Reservation>> getReservationsByCustomerId(int customerId) async {
    try {
      final response = await authenticatedGet('booking/get-booking-by-customer-id?customerId=$customerId');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customer reservations: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservation (booking) by ID
  Future<Reservation?> getReservationById(int reservationId) async {
    try {
      final response = await authenticatedGet('booking/get-booking-by-id?id=$reservationId');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Reservation.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load reservation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get reservations by resource type
  Future<List<Reservation>> getReservationsByResourceType(String resourceType, int hotelId) async {
    try {
      final response = await authenticatedGet('reservations/resource-type/$resourceType?hotelId=$hotelId');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reservations by resource type: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update reservation status
  Future<bool> updateReservationStatus(int reservationId, String status) async {
    try {
      final response = await authenticatedPut(
        'reservations/$reservationId/status',
        body: {'status': status},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update reservation status: ${response.statusCode} - ${response.body}');
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

  // Get available resources by type and date
  Future<List<ReservationResource>> getAvailableResources(
    String resourceType, 
    int hotelId, 
    DateTime date,
    DateTime startTime,
    DateTime endTime
  ) async {
    try {
      final queryParams = {
        'type': resourceType,
        'hotelId': hotelId.toString(),
        'date': date.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      };
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final response = await authenticatedGet('reservation-resources/available?$queryString');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ReservationResource.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load available resources: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all resources by hotel
  Future<List<ReservationResource>> getResourcesByHotelId(int hotelId) async {
    try {
      final response = await authenticatedGet('reservation-resources/hotel/$hotelId');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => ReservationResource.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load resources: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}