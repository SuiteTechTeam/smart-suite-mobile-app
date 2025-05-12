import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweetmanager/Profiles/customers/models/customer_model.dart';

class Customerservice{
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Customerservice();

  // Helper function to get the headers with the token
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


  // POST /api/customer/create-customer
  Future<dynamic> createCustomer(Map<String, dynamic> customer) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/customer/create'),
      headers: headers,
      body: json.encode(customer),
    );

    print('POST /api/customer/create response status: ${response.statusCode}');
    print('POST /api/customer/create response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('Failed to create customer: ${response.statusCode} - ${response.body}');
    }
  }

  // PUT /api/customer/update-customer
  Future<dynamic> updateCustomer(int id,Map<String, dynamic> customer) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/customer/$id'),
      headers: headers,
      body: json.encode(customer),
    );

    print('PUT /api/customer/$id response status: ${response.statusCode}');
    print('PUT /api/customer/$id response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body.isNotEmpty ? json.decode(response.body) : {};
    } else {
      throw Exception('Failed to update customer: ${response.statusCode} - ${response.body}');
    }
  }

  // GET /api/customer/get-all/{hotelId}
  Future<List<Customer>> getCustomerByHotelId(int hotelId) async {
    final headers = await _getHeaders();

    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/get-all-customers/$hotelId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      
      List<dynamic> jsonData = jsonDecode(response.body);

      List<Customer> customers = jsonData.map((element) => Customer.fromJson(element)).toList();

      List<Customer> newList = [];

      List<int> ids = [];

      var validation = false;

      for(int i = 0; i < customers.length; i++)
      {
        if (i + 1 < customers.length && customers[i].id != customers[i + 1].id)
        {
          ids.add(customers[i].id);

          newList.add(customers[i]);
        }
        if(i + 1 == customers.length)
        {
          for(int j = 0; j < ids.length; j++)
          {
            if(customers[i].id == ids[j])
            {
              validation = true;
            }
          }
        }
      }

      if(!validation)
      {
        newList.add(customers[customers.length - 1]);
      }

      return newList;
    } else {
      throw Exception('Failed to load customers by Hotel Id: ${response.statusCode} - ${response.body}');
    }
  }

}