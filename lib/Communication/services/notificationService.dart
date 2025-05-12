import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../IAM/services/auth_service.dart';
import '../models/notification.dart';

class NotificationService {
  final String baseUrl = "https://sweetmanager-api.ryzeon.me"; // Base URL
  final AuthService authService = AuthService(); // AuthService dependency

  NotificationService();

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    if (token == null || JwtDecoder.isExpired(token)) {
      print('Token is missing or expired. Please log in again.');
      throw Exception('Token is missing or expired. Please log in again.');
    }
    print('Retrieved token: $token'); // Debug log
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  // Create a new notification
  Future<bool> createNotification(Notifications notification) async {
    final url = Uri.parse("$baseUrl/api/notifications"); // Endpoint
    final headers = await _getHeaders(); // Fetch headers with token


    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notification.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to create notification');
    }
  }

  // Create a new alert (typesNotificationsId == 2)
  Future<bool> createAlert(Notifications notification) async {
    final headers = await _getHeaders();
    final url = Uri.parse("$baseUrl/api/notifications"); // Endpoint

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(notification.toJson()),
    );

    if (response.statusCode == 200) {
      return true; // Success
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to create alert');
    }
  }

  // Get a notification by ID
  Future<Notifications> getNotificationById(int id) async {
    final url = Uri.parse("$baseUrl/api/notifications/get-notification-by-id/$id"); // Correct endpoint
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers).timeout(Duration(seconds: 15)); // Added timeout

    if (response.statusCode == 200) {
      return Notifications.fromJson(jsonDecode(response.body));
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Notification not found');
    }
  }

  // Fetch all notifications (no filter by type)
  Future<List<Notifications>> getAllNotifications(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/get-all-notifications?hotelId=$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Notifications.fromJson(json)).toList();
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  // Get all notifications filtered by typesNotificationsId = 1 (Messages)
  Future<List<Notifications>> getMessages(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/get-all-notifications?hotelId=$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Notifications.fromJson(json))
          .where((notification) => notification.typesNotificationsId == 1)
          .toList();
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load notifications');
    }
  }

  // Fetch all notifications filtered by typesNotificationsId = 2 (Alerts)
  Future<List<Notifications>> getAlertNotifications(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/get-all-notifications?hotelId=$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => Notifications.fromJson(json))
          .where((notification) => notification.typesNotificationsId == 2) // Filtra solo las alertas
          .toList();
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load alert notifications');
    }
  }

  // Service to fetch all admin and worker IDs
Future<List<int>> getAllAdminIds() async {
  final url = Uri.parse("$baseUrl/admins");
  final headers = await _getHeaders();
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((admin) => admin['id'] as int).toList();
  } else {
    throw Exception('Failed to load admin IDs');
  }
}

Future<List<int>> getAllWorkerIds() async {
  final url = Uri.parse("$baseUrl/workers");
  final headers = await _getHeaders();
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    return data.map((worker) => worker['id'] as int).toList();
  } else {
    throw Exception('Failed to load worker IDs');
  }
}

}
