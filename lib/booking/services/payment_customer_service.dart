import 'dart:convert';
import '../../core/services/base_service.dart';

class PaymentCustomer {
  final int? id;
  final int? guestId;
  final double? finalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentCustomer({
    this.id,
    this.guestId,
    this.finalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentCustomer.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentCustomer(
        id: json['id'],
        guestId: json['guestId'],
        finalAmount: json['finalAmount'] != null 
            ? (json['finalAmount'] is int 
                ? (json['finalAmount'] as int).toDouble() 
                : json['finalAmount'].toDouble())
            : null,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'].toString()) 
            : null,
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'].toString()) 
            : null,
      );
    } catch (e) {
      print('Debug - PaymentCustomer.fromJson parsing error: $e');
      print('Debug - JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'guestId': guestId,
      'finalAmount': finalAmount,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'guestId': guestId,
      'finalAmount': finalAmount ?? 0.0,
    };
  }
}

class PaymentCustomerService extends BaseService {
  PaymentCustomerService({super.httpClient});

  // Helper method to safely parse JSON response that might be a List or Map
  Map<String, dynamic>? _parseJsonResponse(dynamic jsonData, String methodName) {
    try {
      if (jsonData is List) {
        print('Debug - $methodName: API returned List with ${jsonData.length} items');
        if (jsonData.isNotEmpty) {
          final firstItem = jsonData.first;
          if (firstItem is Map<String, dynamic>) {
            print('Debug - $methodName: Using first item from list');
            return firstItem;
          } else {
            print('Debug - $methodName: First item in list is not a Map: ${firstItem.runtimeType}');
            return null;
          }
        } else {
          print('Debug - $methodName: API returned empty list');
          return null;
        }
      } else if (jsonData is Map<String, dynamic>) {
        print('Debug - $methodName: API returned Map directly');
        return jsonData;
      } else {
        print('Debug - $methodName: Unexpected data type: ${jsonData.runtimeType}');
        return null;
      }
    } catch (e) {
      print('Debug - $methodName: Error parsing JSON response: $e');
      return null;
    }
  }

  // Create a new payment customer
  Future<PaymentCustomer> createPaymentCustomer(PaymentCustomer paymentCustomer) async {
    try {
      print('Debug - createPaymentCustomer: Sending data: ${paymentCustomer.toCreateJson()}');
      
      final response = await authenticatedPost(
        'payment-customer',
        body: paymentCustomer.toCreateJson(),
      );

      print('Debug - createPaymentCustomer: Response status: ${response.statusCode}');
      print('Debug - createPaymentCustomer: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If response body is empty or just a success message, return the original payment customer
        if (response.body.isEmpty || response.body.trim() == 'true' || response.body.trim() == 'false') {
          print('Debug - createPaymentCustomer: API returned simple success response, returning original payment customer');
          return paymentCustomer;
        }

        // Try to parse the response
        dynamic jsonData;
        try {
          jsonData = json.decode(response.body);
        } catch (parseError) {
          print('Debug - createPaymentCustomer: JSON Parse Error: $parseError');
          print('Debug - createPaymentCustomer: Response body that failed to parse: "${response.body}"');
          // If we can't parse JSON but got success status, return original payment customer
          return paymentCustomer;
        }

        print('Debug - createPaymentCustomer: Parsed JSON Type: ${jsonData.runtimeType}');
        print('Debug - createPaymentCustomer: Parsed JSON Data: $jsonData');

        // Handle different response formats using helper method
        final paymentCustomerData = _parseJsonResponse(jsonData, 'createPaymentCustomer');
        
        if (paymentCustomerData == null) {
          print('Debug - createPaymentCustomer: Could not parse response, returning original payment customer');
          return paymentCustomer;
        }

        try {
          return PaymentCustomer.fromJson(paymentCustomerData);
        } catch (parseError) {
          print('Debug - createPaymentCustomer: PaymentCustomer.fromJson Error: $parseError');
          print('Debug - createPaymentCustomer: PaymentCustomer Data: $paymentCustomerData');
          return paymentCustomer;
        }
      } else {
        print('Debug - createPaymentCustomer: API Error Status: ${response.statusCode}');
        print('Debug - createPaymentCustomer: API Error Body: ${response.body}');
        throw Exception(
          'Failed to create payment customer: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - createPaymentCustomer Error: $e');
      rethrow;
    }
  }

  // Get payment customer by ID
  Future<PaymentCustomer?> getPaymentCustomerById(int paymentCustomerId) async {
    try {
      final response = await authenticatedGet(
        'payment-customer/$paymentCustomerId',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle different response formats using helper method
        final paymentCustomerData = _parseJsonResponse(jsonData, 'getPaymentCustomerById');
        
        if (paymentCustomerData == null) {
          print('Debug - getPaymentCustomerById: Could not parse response');
          return null;
        }

        try {
          return PaymentCustomer.fromJson(paymentCustomerData);
        } catch (parseError) {
          print('Debug - getPaymentCustomerById: PaymentCustomer.fromJson Error: $parseError');
          print('Debug - getPaymentCustomerById: PaymentCustomer Data: $paymentCustomerData');
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to get payment customer: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - getPaymentCustomerById Error: $e');
      rethrow;
    }
  }

  // Get payment customer by guest ID
  Future<PaymentCustomer?> getPaymentCustomerByGuestId(int guestId) async {
    try {
      final response = await authenticatedGet(
        'payment-customer/by-customer/$guestId',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        // Handle different response formats using helper method
        final paymentCustomerData = _parseJsonResponse(jsonData, 'getPaymentCustomerByGuestId');
        
        if (paymentCustomerData == null) {
          print('Debug - getPaymentCustomerByGuestId: Could not parse response');
          return null;
        }

        try {
          return PaymentCustomer.fromJson(paymentCustomerData);
        } catch (parseError) {
          print('Debug - getPaymentCustomerByGuestId: PaymentCustomer.fromJson Error: $parseError');
          print('Debug - getPaymentCustomerByGuestId: PaymentCustomer Data: $paymentCustomerData');
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to get payment customer by guest ID: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - getPaymentCustomerByGuestId Error: $e');
      rethrow;
    }
  }

  // Update payment customer
  Future<PaymentCustomer> updatePaymentCustomer(int paymentCustomerId, PaymentCustomer paymentCustomer) async {
    try {
      final updateData = paymentCustomer.toJson();
      updateData['id'] = paymentCustomerId;

      print('Debug - updatePaymentCustomer: Sending data: $updateData');

      final response = await authenticatedPut(
        'payment-customer/$paymentCustomerId',
        body: updateData,
      );

      print('Debug - updatePaymentCustomer: Response status: ${response.statusCode}');
      print('Debug - updatePaymentCustomer: Response body: ${response.body}');

      if (response.statusCode == 200) {
        // If response body is empty or just a success message, return the original payment customer
        if (response.body.isEmpty || response.body.trim() == 'true' || response.body.trim() == 'false') {
          print('Debug - updatePaymentCustomer: API returned simple success response, returning original payment customer');
          return paymentCustomer;
        }

        // Try to parse the response
        dynamic jsonData;
        try {
          jsonData = json.decode(response.body);
        } catch (parseError) {
          print('Debug - updatePaymentCustomer: JSON Parse Error: $parseError');
          print('Debug - updatePaymentCustomer: Response body that failed to parse: "${response.body}"');
          // If we can't parse JSON but got success status, return original payment customer
          return paymentCustomer;
        }

        print('Debug - updatePaymentCustomer: Parsed JSON Type: ${jsonData.runtimeType}');
        print('Debug - updatePaymentCustomer: Parsed JSON Data: $jsonData');

        // Handle different response formats using helper method
        final paymentCustomerData = _parseJsonResponse(jsonData, 'updatePaymentCustomer');
        
        if (paymentCustomerData == null) {
          print('Debug - updatePaymentCustomer: Could not parse response, returning original payment customer');
          return paymentCustomer;
        }

        try {
          return PaymentCustomer.fromJson(paymentCustomerData);
        } catch (parseError) {
          print('Debug - updatePaymentCustomer: PaymentCustomer.fromJson Error: $parseError');
          print('Debug - updatePaymentCustomer: PaymentCustomer Data: $paymentCustomerData');
          return paymentCustomer;
        }
      } else {
        print('Debug - updatePaymentCustomer: API Error Status: ${response.statusCode}');
        print('Debug - updatePaymentCustomer: API Error Body: ${response.body}');
        throw Exception(
          'Failed to update payment customer: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Debug - updatePaymentCustomer Error: $e');
      rethrow;
    }
  }

  // Get or create payment customer for a guest
  Future<PaymentCustomer> getOrCreatePaymentCustomer(int guestId, {double initialAmount = 0.0}) async {
    try {
      // First try to get existing payment customer
      PaymentCustomer? existingCustomer = await getPaymentCustomerByGuestId(guestId);
      
      if (existingCustomer != null) {
        return existingCustomer;
      }

      // If not exists, create new one
      PaymentCustomer newCustomer = PaymentCustomer(
        guestId: guestId,
        finalAmount: initialAmount,
      );

      return await createPaymentCustomer(newCustomer);
    } catch (e) {
      rethrow;
    }
  }
} 