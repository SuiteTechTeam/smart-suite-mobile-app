import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import '../models/reservation_resource.dart';
import '../../iam/services/storage_service.dart';
import '../../core/config/app_config.dart';
import 'dart:io';

class ReservationService {
  final String baseUrl = AppConfig.smartSuiteBaseUrl;
  final StorageService _storageService = StorageService();
  
  // HTTP client with timeout configuration
  static const Duration _defaultTimeout = Duration(seconds: 30);

  ReservationService();  // Helper function to get headers with the token
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
      rethrow;
    }
  }
  // Create a new reservation
  Future<bool> createReservation(Reservation reservation) async {
    try {
      final headers = await _getHeaders();
      final response = await _postWithTimeout(
        '$baseUrl/api/v1/reservations/create',
        headers,
        json.encode(reservation.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
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
      final response = await _getWithTimeout('$baseUrl/api/v1/reservations/hotel/$hotelId', headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
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
      final response = await _getWithTimeout('$baseUrl/api/v1/reservations/customer/$customerId', headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Reservation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
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
