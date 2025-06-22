import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Constantes para los nombres de claims
  static const String sidClaimKey =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/sid';
  static const String roleClaimKey =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
  static const String localityClaimKey =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/locality';
  static const String emailClaimKey =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
  static const String emailSimpleKey = 'Email';
  static const String userIdSimpleKey = 'UserId';

  AuthService();

  /// Get the JWT token from secure storage
  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  /// Get user ID from JWT (ClaimTypes.Sid)
  Future<int?> getUserId() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);

      // Intentar con el claim completo primero
      var sid = decoded[sidClaimKey];

      // Si no existe, probar con el claim simple
      sid ??= decoded[userIdSimpleKey] ?? decoded['sid'];

      if (sid != null) return int.tryParse(sid.toString());
    }
    return null;
  }

  /// Get user role from JWT (ClaimTypes.Role)
  Future<String?> getUserRole() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);

      // Intentar con el claim completo primero
      final role = decoded[roleClaimKey] ?? decoded['role'];

      if (role != null) {
        final roleStr = role.toString();
        // If the role has a prefix like ROLE_, strip it off
        if (roleStr.startsWith('ROLE_')) {
          return roleStr.substring(5).toLowerCase();
        }
        return roleStr.toLowerCase();
      }
    }
    return null;
  }

  /// Get hotel ID from JWT (ClaimTypes.Locality)
  Future<int?> getHotelIdFromToken() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);

      // Intentar con el claim completo primero
      final hotel = decoded[localityClaimKey] ?? decoded['locality'];

      if (hotel != null && hotel.toString().isNotEmpty) {
        return int.tryParse(hotel.toString());
      }
    }
    return null;
  }

  /// Get user email from JWT (ClaimTypes.Email)
  Future<String?> getUserEmail() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);

      // Intentar con el claim completo primero, luego con claim simple, y finalmente con la versión abreviada
      final email =
          decoded[emailClaimKey] ?? decoded[emailSimpleKey] ?? decoded['email'];

      return email?.toString();
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final userInfo = await getUserInfo();
      if (userInfo == null) return null;

      // Agregar roleId si está disponible
      final roleId = await getUserId();
      if (roleId != null) {
        userInfo['roleId'] = roleId;
      }

      return userInfo;
    } catch (e) {
      return null;
    }
  }

  /// Get all user information from JWT
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);

      // Obtener claims usando nombres completos primero, luego versiones simplificadas como respaldo
      final sidClaim =
          decoded[sidClaimKey] ?? decoded[userIdSimpleKey] ?? decoded['sid'];
      final roleClaim = decoded[roleClaimKey] ?? decoded['role'];
      final localityClaim = decoded[localityClaimKey] ?? decoded['locality'];
      final emailClaim =
          decoded[emailClaimKey] ?? decoded[emailSimpleKey] ?? decoded['email'];

      return {
        'id': sidClaim != null ? int.tryParse(sidClaim.toString()) : null,
        'role': roleClaim?.toString(),
        'hotelId': localityClaim != null && localityClaim.toString().isNotEmpty
            ? int.tryParse(localityClaim.toString())
            : null,
        'email': emailClaim?.toString(),
      };
    }
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
