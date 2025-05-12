import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:sweetmanager/Profiles/providers/models/provider_model.dart';

class ProviderService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  ProviderService();

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

  // Creates a new provider
  // Endpoint: POST /api/provider/create-provider
  Future<bool> createProvider(Map<String, dynamic> providerData) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/provider/create-provider'),
      headers: headers,
      body: json.encode(providerData),
    );

    print('POST /api/provider/create-provider response status: ${response.statusCode}');
    print('POST /api/provider/create-provider response body: ${response.body}');

    // Verifica si la creación fue exitosa
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Failed to create provider: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  // Updates an existing provider
  // Endpoint: PUT /api/provider/update-provider
  Future<Map<String, dynamic>> updateProvider(Map<String, dynamic> provider) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/provider/update-provider'),
      headers: headers,
      body: json.encode(provider),
    );

    print('PUT /api/provider/update-provider status: ${response.statusCode}');
    print('PUT /api/provider/update-provider body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      // Manejo de errores más detallado
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      print('Error details: $errorData');
      throw Exception('Failed to update provider: ${response.statusCode} - $errorData');
    }
  }

  // Retrieves all providers for a specific hotel
  // Endpoint: GET /api/provider/get-all/{hotelId}
  Future<List<Provider>> getProvidersByHotelId(int hotelId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/provider/get-all/$hotelId'),
      headers: headers,
    );
    if (response.statusCode == 200) {


      List<dynamic> jsonData =  json.decode(response.body);
    
      List<Provider> providers = jsonData.map((element)=> Provider.fromJson(element)).toList();
    
      List<Provider> newList = [];

      List<int> ids = [];

      var validation = false;

      for(int i = 0; i < providers.length; i++)
      {
        if (i + 1 < providers.length && providers[i].id != providers[i + 1].id)
        {
          ids.add(providers[i].id!);

          newList.add(providers[i]);
        }
        if(i + 1 == providers.length)
        {
          for(int j = 0; j < ids.length; j++)
          {
            if(providers[i].id == ids[j])
            {
              validation = true;
            }
          }
        }
      }

      if(!validation)
      {
        newList.add(providers[providers.length - 1]);
      }

      return newList;
    } else {
      // Manejo de errores más detallado
      final errorData = response.body.isNotEmpty ? json.decode(response.body) : {};
      print('Error details: $errorData');
      throw Exception('Failed to load providers by Hotel Id: ${response.statusCode} - $errorData');
    }
  }
}
