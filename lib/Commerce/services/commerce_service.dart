import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sweetmanager/Commerce/models/contract_owners.dart';
import 'package:sweetmanager/Commerce/models/payment_customer.dart';
import 'package:sweetmanager/Commerce/models/payment_owner.dart';

class CommerceService {
  final String baseUrl = 'https://sweetmanager-api.ryzeon.me';

  final storage = const FlutterSecureStorage();

  Future<bool> registerContract(int subscriptionId, int ownersId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/create-contract-owner'), 
       headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
       },
       body: jsonEncode({
        'subscriptionId': subscriptionId,
        'ownersId': ownersId,
        'state': 'ACTIVE'
       }));

       if(response.statusCode == 200)
       {
          return true;
       }

       return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<ContractOwners?> fetchContractByOwnerId(int ownersId) async
  {
    try {
      final String? token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-contract-by-owner-id?ownerId=$ownersId'), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        ContractOwners object = ContractOwners(id: jsonData['id'], subscriptionId: jsonData['subscriptionId'],
        ownersId: jsonData['ownersId'], startDate: jsonData['startDate'], finalDate: jsonData['finalDate'], status: jsonData['status']);

        return object;
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  } 



  Future<bool> createPaymentOwner(int ownersId, String description, double finalAmount) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/create-payment-owner'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'ownerId': ownersId,
        'description':description,
        'finalAmount': finalAmount
      }));

      if(response.statusCode == 200)
      {
        return true;
      }

      return false;
    }
    catch (e) {
      rethrow;
    }
  }

  Future<PaymentOwner?> fetchPaymentByOwnerId(int ownerId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-payments-owner-id?ownerId=$ownerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        PaymentOwner object = PaymentOwner(id: jsonData['id'], ownersId: jsonData['ownersId'], description: jsonData['description'],
         finalAmount: jsonData['finalAmount']);

         return object;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createPaymentcustomer(int customerId, double finalAmount) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/create-payment-customer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'customerId': customerId,
        'finalAmount': finalAmount
      }));

      if(response.statusCode == 200)
      {
        return true;
      }

      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentCustomer?> fetchPaymentByCustomerId(int customerId) async
  {
    try {
      final token = storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-payments-customer-id?customerId=$customerId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },);

      if(response.statusCode == 200)
      {
        var jsonData = jsonDecode(response.body);

        PaymentCustomer object = PaymentCustomer(id: jsonData['id'], customersId: jsonData['customersId'], finalAmount: jsonData['finalAmount']);

        return object;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<PaymentCustomer?> fetchPaymentCustomerByHotelId(int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.get(Uri.parse('$baseUrl/get-payments-customer-hotel-id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      });

      if(response.statusCode == 200)
      {
        var jsonData = json.decode(response.body);

        PaymentCustomer object = PaymentCustomer(id: jsonData['id'], customersId: jsonData['customersId'], finalAmount: jsonData['finalAmount']);

        return object;
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> registerRoomTypes(String name, double price) async 
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/api/types-rooms/create-type-room'),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
          'description': name,
          'price': price
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

  Future<bool> registerWorkerAreas(String name, int hotelId) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/api/v1/worker-area/create-worker-area'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'name': name,
        'hotelId': hotelId
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

  Future<bool> registerAssignmentWorker(int workerAreasId, int workersId, int adminsId, String startDate, String finalDate) async
  {
    try {
      final token = await storage.read(key: 'token');

      final response = await http.post(Uri.parse('$baseUrl/api/v1/assignment-worker/create-assignment-worker'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'workerAreasId': workerAreasId,
        'workersId': workersId,
        'adminsId': adminsId,
        'startDate': startDate,
        'finalDate': finalDate,
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

  

}