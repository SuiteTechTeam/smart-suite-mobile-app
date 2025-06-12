import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'storage_service.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final StorageService _storageService = StorageService();

  AuthService();

  /// Get the JWT token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// Get user ID from storage
  Future<int?> getUserId() async {
    try {
      final user = await _storageService.getAuthenticatedUser();
      return user?.id;
    } catch (e) {
      return null;
    }
  }

  /// Get user role from storage
  Future<String?> getUserRole() async {
    try {
      final user = await _storageService.getAuthenticatedUser();
      return user?.role;
    } catch (e) {
      return null;
    }
  }

  /// Get user roleId from storage
  Future<int?> getUserRoleId() async {
    try {
      final user = await _storageService.getAuthenticatedUser();
      return user?.roleId;
    } catch (e) {
      return null;
    }
  }

  /// Get user email from storage
  Future<String?> getUserEmail() async {
    try {
      final user = await _storageService.getAuthenticatedUser();
      return user?.email;
    } catch (e) {
      return null;
    }
  }

  /// Get all user information from storage (respuesta del endpoint sign-in)
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final user = await _storageService.getAuthenticatedUser();
      if (user != null) {
        return user.toJson();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get hotel ID from JWT token (if present)
  Future<int?> getHotelIdFromToken() async {
    // Si el modelo AuthenticatedUser tiene hotelId, aquí deberías retornarlo
    // Si no, deberías extender AuthenticatedUser para incluirlo
    return null;
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
    await storage.delete(key: 'authenticated_user');
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
