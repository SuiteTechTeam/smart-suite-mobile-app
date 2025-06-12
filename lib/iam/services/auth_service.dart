import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  AuthService();

  /// Get the JWT token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// Get user ID from JWT token
  Future<int?> getUserId() async {
    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return int.tryParse(decodedToken['sub'] ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user role from JWT token
  Future<String?> getUserRole() async {
    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user email from JWT token
  Future<String?> getUserEmail() async {
    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get hotel ID from JWT token (if present)
  Future<int?> getHotelIdFromToken() async {
    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        String? locality = decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'];
        return locality != null ? int.tryParse(locality) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all user information from JWT token
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      String? token = await getToken();
      if (token != null) {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        return {
          'id': int.tryParse(decodedToken['sub'] ?? ''),
          'email': decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'],
          'role': decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'],
          'hotelId': decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'] != null
              ? int.tryParse(decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality'])
              : null,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      String? token = await getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      String? token = await getToken();
      if (token != null) {
        return JwtDecoder.isExpired(token);
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Clear stored authentication data
  Future<void> clearAuth() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'selected_hotel_id');
  }

  /// Store selected hotel ID
  Future<void> setSelectedHotelId(int hotelId) async {
    await storage.write(key: 'selected_hotel_id', value: hotelId.toString());
  }

  /// Get selected hotel ID from storage
  Future<int?> getSelectedHotelId() async {
    try {
      String? hotelIdStr = await storage.read(key: 'selected_hotel_id');
      return hotelIdStr != null ? int.tryParse(hotelIdStr) : null;
    } catch (e) {
      return null;
    }
  }
}
