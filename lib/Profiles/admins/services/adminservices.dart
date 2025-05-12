import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Profiles/admins/models/admin_model.dart';

class AdminService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AdminService();

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

  // POST
  Future<dynamic> createAdmin(Map<String, dynamic> adminData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/authentication/sign-up-admin'),
      headers: headers,
      body: json.encode(adminData),
    );

    print('POST /api/v1/authentication/sign-up-admin response status: ${response.statusCode}');
    print('POST /api/v1/authentication/sign-up-admin response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('Failed to create admin: ${response.statusCode} - ${response.body}');
    }
  }

  // GET /api/v1/user/get-all-admins con hotelId como parámetro de consulta
  Future<List<Admin>> getAdminsByHotelId(int hotelId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/user/get-all-admins?hotelId=$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {

      List<dynamic>data =  json.decode(response.body);

      var admins = data.map((element)=> Admin.fromJson(element)).toList();

      List<Admin> newList = [];

      List<int> ids = [];

      var validation = false;

      for(int i = 0; i < admins.length; i++)
      {
        if(i + 1 < admins.length && admins[i].id != admins[i + 1].id)
        {
          ids.add(admins[i].id);

          newList.add(admins[i]);
        }
        if(i + 1 == admins.length)
        {
          for(int j = 0; j < ids.length; j++)
          {
            if(admins[i].id == ids[j])
            {
              validation = true;
            }
          }
        }
      }

      if(!validation)
      {
        newList.add(admins[admins.length - 1]);
      }

      return newList;
    } else {
      throw Exception('Failed to load admins by Hotel ID: ${response.statusCode} - ${response.body}');
    }
  }
}
