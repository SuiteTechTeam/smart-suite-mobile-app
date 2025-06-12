import 'dart:convert';
import '../../core/services/base_service.dart';
import 'auth_service.dart';

class UserService extends BaseService {
  final AuthService _authService = AuthService();
  UserService({super.httpClient});

  // Get user info by role and id (from JWT via AuthService)
  Future<Map<String, dynamic>?> getUserInfoFromApi() async {
    print('[UserService] getUserInfoFromApi called');
    final userInfo = await _authService.getUserInfo();
    print('[UserService] userInfo from JWT: '
        'role: \\${userInfo?['role']} id: \\${userInfo?['id']} roleId: \\${userInfo?['roleId']}');
    if (userInfo == null) return null;
    final role = userInfo['role'];
    final id = userInfo['id'];
    final roleId = userInfo['roleId'];
    if (role == null || id == null) return null;
    String endpoint;
    if (role.toLowerCase() == 'admin') {
      endpoint = 'User/admins/$id';
    } else if (role.toLowerCase() == 'owner') {
      endpoint = 'User/owners/$id';
    } else if (role.toLowerCase() == 'guest') {
      endpoint = 'User/guests/$id';
    } else {
      print('[UserService] Unknown role: $role');
      return null;
    }
    print('[UserService] Making GET request to endpoint: $endpoint');
    final response = await authenticatedGet(endpoint);
    print('[UserService] Response status: \\${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('[UserService] Response data: $data');
      // Incluye el roleId en la info de usuario
      return {
        ...data,
        'roleId': roleId,
        'role': role,
        'id': id,
      };
    }
    print('[UserService] Request failed with status: \\${response.statusCode}');
    return null;
  }

  // Update user info
  Future<bool> updateUserInfo(Map<String, dynamic> data) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) return false;
    final role = userInfo['role'];
    final id = userInfo['id'];
    if (role == null || id == null) return false;
    String endpoint;
    if (role.toLowerCase() == 'admin') {
      endpoint = 'User/admins/$id';
    } else if (role.toLowerCase() == 'owner') {
      endpoint = 'User/owners/$id';
    } else if (role.toLowerCase() == 'guest') {
      endpoint = 'User/guests/$id';
    } else {
      return false;
    }
    final response = await authenticatedPut(endpoint, body: data);
    return response.statusCode == 200;
  }

  // Change password (if endpoint exists)
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final userInfo = await _authService.getUserInfo();
    if (userInfo == null) return false;
    final role = userInfo['role'];
    final id = userInfo['id'];
    if (role == null || id == null) return false;
    String endpoint;
    if (role.toLowerCase() == 'admin') {
      endpoint = 'User/admins/$id/password';
    } else if (role.toLowerCase() == 'owner') {
      endpoint = 'User/owners/$id/password';
    } else if (role.toLowerCase() == 'guest') {
      endpoint = 'User/guests/$id/password';
    } else {
      return false;
    }
    final response = await authenticatedPut(endpoint, body: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    return response.statusCode == 200;
  }
}
