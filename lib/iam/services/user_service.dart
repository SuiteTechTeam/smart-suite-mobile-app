import 'dart:convert';
import '../../core/services/base_service.dart';
import 'auth_service.dart';

class UserService extends BaseService {
  final AuthService _authService = AuthService();
  UserService({super.httpClient});

  // Get user info by role and id (from JWT via AuthService)
  Future<Map<String, dynamic>?> getUserInfoFromApi() async {
    print('[UserService] getUserInfoFromApi called');
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        print('[UserService] No user info from token');
        return null;
      }

      final roleRaw = userInfo['role']?.toString().toUpperCase();
      final id = userInfo['id'];
      if (roleRaw == null || id == null) {
        print('[UserService] Missing role or id in token');
        return null;
      }

      // Parse the role from JWT format (e.g., "ROLE_OWNER" -> "owner")
      String role;
      if (roleRaw.startsWith('ROLE_')) {
        role = roleRaw.substring(5).toLowerCase(); // Remove 'ROLE_' prefix
      } else {
        role = roleRaw.toLowerCase();
      }

      print('[UserService] Role: $role, ID: $id');

      String endpoint;
      if (role == 'admin') {
        endpoint = 'user/admins/$id';
      } else if (role == 'owner') {
        endpoint = 'user/owners/$id';
      } else if (role == 'guest') {
        endpoint = 'user/guests/$id';
      } else {
        print('[UserService] Unknown role: $role');
        return null;
      }

      print('[UserService] Calling API endpoint: $endpoint');
      final response = await authenticatedGet(endpoint);
      print('[UserService] API response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[UserService] Data received from API');

        // Include the role info in returned data
        return {
          ...data,
          'role': role,
          'id': id,
        };
      } else {
        print('[UserService] Failed to get user info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[UserService] Error getting user info: $e');
    }
    return null;
  }

  // Update user info
  Future<bool> updateUserInfo(Map<String, dynamic> data) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        print('[UserService] No user info from token for update');
        return false;
      }
      
      final roleRaw = userInfo['role']?.toString().toUpperCase();
      final id = userInfo['id'];
      
      if (roleRaw == null || id == null) {
        print('[UserService] Missing role or id in token for update');
        return false;
      }
      
      // Parse the role from JWT format (e.g., "ROLE_OWNER" -> "owner")
      String role;
      if (roleRaw.startsWith('ROLE_')) {
        role = roleRaw.substring(5).toLowerCase(); // Remove 'ROLE_' prefix
      } else {
        role = roleRaw.toLowerCase();
      }
      
      print('[UserService] Update role: $role, ID: $id');
      
      String endpoint;
      if (role == 'admin') {
        endpoint = 'user/admins/$id';
      } else if (role == 'owner') {
        endpoint = 'user/owners/$id';
      } else if (role == 'guest') {
        endpoint = 'user/guests/$id';
      } else {
        print('[UserService] Unknown role for update: $role');
        return false;
      }
      
      print('[UserService] Calling update API endpoint: $endpoint');
      final response = await authenticatedPut(endpoint, body: data);
      print('[UserService] API update response: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('[UserService] Error updating user info: $e');
      return false;
    }
  }

  // Change password (if endpoint exists)
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final userInfo = await _authService.getUserInfo();
      if (userInfo == null) {
        print('[UserService] No user info from token for password change');
        return false;
      }
      
      final roleRaw = userInfo['role']?.toString().toUpperCase();
      final id = userInfo['id'];
      
      if (roleRaw == null || id == null) {
        print('[UserService] Missing role or id in token for password change');
        return false;
      }
      
      // Parse the role from JWT format (e.g., "ROLE_OWNER" -> "owner")
      String role;
      if (roleRaw.startsWith('ROLE_')) {
        role = roleRaw.substring(5).toLowerCase(); // Remove 'ROLE_' prefix
      } else {
        role = roleRaw.toLowerCase();
      }
      
      print('[UserService] Change password role: $role, ID: $id');
      
      String endpoint;
      if (role == 'admin') {
        endpoint = 'user/admins/$id/password';
      } else if (role == 'owner') {
        endpoint = 'user/owners/$id/password';
      } else if (role == 'guest') {
        endpoint = 'user/guests/$id/password';
      } else {
        print('[UserService] Unknown role for password change: $role');
        return false;
      }
      
      print('[UserService] Calling password change API endpoint: $endpoint');
      final response = await authenticatedPut(endpoint, body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      print('[UserService] API password change response: ${response.statusCode}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('[UserService] Error changing password: $e');
      return false;
    }
  }
}
