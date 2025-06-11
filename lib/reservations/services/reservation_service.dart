import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/reservation.dart';
import '../models/reservation_resource.dart';

class ReservationService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ReservationService();

  // Helper function to get headers with the token
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

  // Create a new reservation
  Future<bool> createReservation(Reservation reservation) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/reservations/create'),
        headers: headers,
        body: json.encode(reservation.toJson()),
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

  // Get all reservations for a hotel
  Future<List<Reservation>> getReservationsByHotelId(int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/hotel/$hotelId'),
        headers: headers,
      );

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

  // Get reservations by customer
  Future<List<Reservation>> getReservationsByCustomerId(int customerId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/customer/$customerId'),
        headers: headers,
      );

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

  // Get reservations by resource type
  Future<List<Reservation>> getReservationsByResourceType(String resourceType, int hotelId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/resource-type/$resourceType?hotelId=$hotelId'),
        headers: headers,
      );

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
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/reservations/$reservationId/status'),
        headers: headers,
        body: json.encode({'status': status}),
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

  // Get reservation by ID
  Future<Reservation?> getReservationById(int reservationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservations/$reservationId'),
        headers: headers,
      );

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

  // Get available resources by type and date
  Future<List<ReservationResource>> getAvailableResources(
    String resourceType, 
    int hotelId, 
    DateTime date,
    DateTime startTime,
    DateTime endTime
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservation-resources/available?'
          'type=$resourceType&hotelId=$hotelId&date=${date.toIso8601String()}'
          '&startTime=${startTime.toIso8601String()}&endTime=${endTime.toIso8601String()}'),
        headers: headers,
      );

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
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/reservation-resources/hotel/$hotelId'),
        headers: headers,
      );

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
