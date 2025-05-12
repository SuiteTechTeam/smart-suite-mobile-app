import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweetmanager/Commerce/models/role_response.dart';
import 'package:http/http.dart' as http;

class WorkAreaService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/v1/worker-area';

  final storage = const FlutterSecureStorage();
  
  Future<RoleResponse?> getWorkAreaByWorkerId(int workersId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-worker-areas-by-worker-id?workerId=$workersId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        RoleResponse object = RoleResponse(role: jsonData['role']);

        return object;
      }
      else
      {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}