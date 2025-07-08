import 'dart:convert';
import 'dart:math';
import '../../core/services/base_service.dart';
import '../models/sign_up_request.dart';
import 'auth_api_service.dart';

class Guest {
  final int id;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String state;

  Guest({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.phone,
    required this.state,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      surname: json['surname'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'email': email,
      'phone': phone,
      'state': state,
    };
  }

  String get fullName => '$name $surname';
  String get displayName => '$fullName ($email)';
}

class GuestService extends BaseService {
  final AuthApiService _authApiService;

  GuestService({super.httpClient}) : _authApiService = AuthApiService();

  // Get all guests for a hotel
  Future<List<Guest>> getAllGuests({
    int? hotelId,
    String? email,
    String? phone,
    String? state,
  }) async {
    try {
      // Build query parameters
      Map<String, String> queryParams = {};
      if (hotelId != null && hotelId > 0) queryParams['hotelId'] = hotelId.toString();
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (phone != null && phone.isNotEmpty) queryParams['phone'] = phone;
      if (state != null && state.isNotEmpty) queryParams['state'] = state;

      String queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      String endpoint = 'user/guests';
      if (queryString.isNotEmpty) {
        endpoint += '?$queryString';
      }

      final response = await authenticatedGet(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Guest.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get guests: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get guest by ID
  Future<Guest?> getGuestById(int guestId) async {
    try {
      final response = await authenticatedGet('user/guests/$guestId');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Guest.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to get guest: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new guest with random password
  Future<Guest> createGuest({
    required String name,
    required String surname,
    required String email,
    required String phone,
  }) async {
    try {
      // Generate random password
      String randomPassword = _generateRandomPassword();

      // Create SignUpRequest
      SignUpRequest signUpRequest = SignUpRequest(
        name: name,
        surname: surname,
        phone: phone,
        email: email,
        password: randomPassword,
      );

      // Register guest
      await _authApiService.signUpGuest(signUpRequest);

      // Get the created guest by email
      List<Guest> guests = await getAllGuests(email: email);
      
      if (guests.isNotEmpty) {
        Guest createdGuest = guests.first;
        
        // Return guest with password info for display
        return createdGuest;
      } else {
        throw Exception('Guest created but could not retrieve from API');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update guest information
  Future<bool> updateGuest(int guestId, Map<String, dynamic> data) async {
    try {
      final response = await authenticatedPut(
        'user/guests/$guestId',
        body: data,
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // Generate random password
  String _generateRandomPassword() {
    const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final Random random = Random.secure();
    
    String password = '';
    for (int i = 0; i < 12; i++) {
      password += chars[random.nextInt(chars.length)];
    }
    
    return password;
  }

  // Search guests by name or email
  Future<List<Guest>> searchGuests(String query) async {
    try {
      List<Guest> allGuests = await getAllGuests();
      
      return allGuests.where((guest) {
        final searchQuery = query.toLowerCase();
        return guest.name.toLowerCase().contains(searchQuery) ||
               guest.surname.toLowerCase().contains(searchQuery) ||
               guest.email.toLowerCase().contains(searchQuery) ||
               guest.fullName.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
} 