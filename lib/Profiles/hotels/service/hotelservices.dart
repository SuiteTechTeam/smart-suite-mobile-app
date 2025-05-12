import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';

class HotelService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me/api/hotel';

  final storage = const FlutterSecureStorage();


  Future<List<Hotel>> fetchHotels() async 
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });

      if(response.statusCode == 200)
      {
        final List<dynamic> jsonList =  jsonDecode(response.body);

        return jsonList.map((json) => Hotel.fromJson(json)).toList();
      }
      else{
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  // Add a new hotel
  Future<Hotel?> registerHotel(Hotel hotel) async {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'name': hotel.name,
          'address': hotel.address,
          'phone': hotel.phoneNumber,
          'email': hotel.email,
          'ownersId': hotel.ownerId,
          'description': hotel.description
        }),
      );

      if (response.statusCode == 200) {
        return Hotel(
            id: 0,
            name: hotel.name,
            address: hotel.address,
            phoneNumber: hotel.phoneNumber,
            email: hotel.email,
            description: hotel.description,
            ownerId: hotel.ownerId
        );
      }
      else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}