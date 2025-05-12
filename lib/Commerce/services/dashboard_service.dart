import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:sweetmanager/Commerce/models/comparative_incomes.dart';

class DashboardService {

  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final storage = const FlutterSecureStorage();

  Future<int> fetchRoomsCount(int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/api/v1/user/get-room-count?hotelId=$hotelId'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        int count = jsonData['count'];

        return count;
      }
      else
      {
        return 0;
      }

    } catch (e) {
      rethrow;
    }
  }

  
  Future<int> fetchWorkersCount(int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/api/v1/user/get-worker-count?hotelId=$hotelId'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        int count = jsonData['count'];

        return count;
      }
      else
      {
        return 0;
      }
    } catch (e) {
      rethrow;
    }
  }

  
  Future<int> fetchAdminsCount(int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/api/v1/user/get-admin-count?hotelId=$hotelId'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        int count = jsonData['count'];

        return count;
      }
      else
      {
        return 0;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ComparativeIncomes>> fetchComparativeIncomesData(int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-comparative-incomes-by-hotel-id?hotelId=$hotelId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if(response.statusCode == 200)
      {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((item) => ComparativeIncomes.fromJson(item)).toList();
      }
      else
      {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

}