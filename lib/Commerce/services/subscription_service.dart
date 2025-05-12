import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'package:sweetmanager/Commerce/models/contract_owners.dart';

class SubscriptionService {
  final baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final storage = const FlutterSecureStorage();

  Future<bool> createContractOwner(ContractOwners contractOwner) async
  {
    try {
      var token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/create-contract-owner'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'subscriptionId': contractOwner.subscriptionId,
        'ownersId': contractOwner.ownersId,
        'state': 'ACTIVE'
      }));

      if(response.statusCode == 200)
      {
        return true;
      }
      else
      {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ContractOwners?> fetchContractByOwnerId(int ownerId) async
  {
    try {
      var token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-contract-by-owner-id?ownerId=$ownerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });
  
      if(response.statusCode == 200)
      {
        var jsonResponse = jsonDecode(response.body);

        return ContractOwners(id: jsonResponse['id'], subscriptionId: jsonResponse['subscriptionId'], ownersId: jsonResponse['ownersId'],
         startDate: jsonResponse['startDate'], finalDate: jsonResponse['endDate'], status: jsonResponse['state']);
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