import 'package:flutter/foundation.dart';

import '../../iam/services/auth_service.dart';
import '../../core/services/base_service.dart';

/// Utility class for hotel-specific authentication and authorization validations
/// Centralizes all security checks for hotel operations
class HotelAuthValidator {
  static final AuthService _authService = AuthService();

  /// Validates if the current user is an owner
  /// Throws AccessDeniedException if user is not an owner
  static Future<void> validateOwnerAccess() async {
    final userRole = await _authService.getUserRole();
    if (userRole?.toLowerCase() != 'owner') {
      throw AccessDeniedException('Access denied. Only owners can perform this action.');
    }
  }

  /// Gets the authenticated user's ID, ensuring they are an owner
  /// Throws AccessDeniedException if user is not an owner
  /// Throws AuthenticationException if user ID not found
  static Future<int> getAuthenticatedOwnerId() async {
    await validateOwnerAccess();
    
    final userId = await _authService.getUserId();
    if (userId == null) {
      throw AuthenticationException('User ID not found. Please login again.');
    }
    
    return userId;
  }

  /// Validates if the current user can access a specific hotel
  /// For owners: Ensures they own the hotel
  /// For admin/guest: Allows access (backend will handle specific permissions)
  static Future<void> validateHotelAccess(int hotelId, Future<Map<String, dynamic>?> Function(int) getHotelById) async {
    final userRole = await _authService.getUserRole();
    
    if (userRole?.toLowerCase() == 'owner') {
      final userId = await _authService.getUserId();
      if (userId == null) {
        throw AuthenticationException('User ID not found. Please login again.');
      }
      
      // For owners, verify they own this hotel
      final hotel = await getHotelById(hotelId);
      if (hotel != null && hotel['ownerId'] != userId) {
        throw AccessDeniedException('Access denied. You can only access your own hotels.');
      }
    }
    // Admin and Guest access will be handled by backend permissions
  }

  /// Validates if the requesting user can access hotels for a specific owner
  /// Only allows access if the requesting user is the same owner
  static Future<void> validateOwnerHotelsAccess(int requestedOwnerId) async {
    final userRole = await _authService.getUserRole();
    
    if (userRole?.toLowerCase() == 'owner') {
      final userId = await _authService.getUserId();
      if (userId != requestedOwnerId) {
        throw AccessDeniedException('Access denied. You can only view your own hotels.');
      }
    }
    // Admin access will be handled by backend permissions
  }

  /// Check if current user is authenticated and active
  static Future<void> validateAuthentication() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (!isAuthenticated) {
      throw AuthenticationException('User not authenticated. Please login.');
    }
  }

  /// Get current user information safely
  static Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      await validateAuthentication();
      
      final userId = await _authService.getUserId();
      final userRole = await _authService.getUserRole();
      final userEmail = await _authService.getUserEmail();
      
      return {
        'id': userId,
        'role': userRole,
        'email': userEmail,
      };
    } catch (e) {
      return null;
    }
  }

  /// Check if current user is an owner without throwing exceptions
  static Future<bool> isCurrentUserOwner() async {
    try {
      final role = await _authService.getUserRole();
      debugPrint('[HotelAuthValidator] Checking if current user is owner. Role: $role');
      
      if (role == null) return false;
      
      // Check for "owner" or "ROLE_OWNER" in various formats
      final String normalizedRole = role.toLowerCase();
      
      // Direct comparison with lowercase
      if (normalizedRole == 'owner') return true;
      
      // Check for ROLE_ prefix (case insensitive)
      if (normalizedRole == 'role_owner') return true;
      
      // Check if prefix is present and strip it
      if (role.toUpperCase().startsWith('ROLE_')) {
        final strippedRole = role.substring(5).toLowerCase();
        return strippedRole == 'owner';
      }
      
      debugPrint('[HotelAuthValidator] User is not an owner. Role: $role');
      return false;
    } catch (e) {
      debugPrint('[HotelAuthValidator] Error checking if user is owner: $e');
      return false;
    }
  }

  /// Check if current user is an admin without throwing exceptions
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final role = await _authService.getUserRole();
      return role?.toLowerCase() == 'admin';
    } catch (e) {
      return false;
    }
  }

  /// Check if current user is a guest without throwing exceptions
  static Future<bool> isCurrentUserGuest() async {
    try {
      final role = await _authService.getUserRole();
      return role?.toLowerCase() == 'guest';
    } catch (e) {
      return false;
    }
  }

  /// Get user's permissions for hotel operations
  static Future<Map<String, bool>> getUserPermissions() async {
    try {
      final userInfo = await getCurrentUserInfo();
      if (userInfo == null) {
        return {
          'canCreateHotel': false,
          'canUpdateHotel': false,
          'canDeleteHotel': false,
          'canViewAllHotels': false,
          'canViewOwnHotels': false,
        };
      }

      final role = userInfo['role']?.toString().toLowerCase();
      
      switch (role) {
        case 'owner':
          return {
            'canCreateHotel': true,
            'canUpdateHotel': true,
            'canDeleteHotel': true,
            'canViewAllHotels': false,
            'canViewOwnHotels': true,
          };
        case 'admin':
          return {
            'canCreateHotel': false,
            'canUpdateHotel': false,
            'canDeleteHotel': false,
            'canViewAllHotels': true,
            'canViewOwnHotels': false,
          };
        case 'guest':
          return {
            'canCreateHotel': false,
            'canUpdateHotel': false,
            'canDeleteHotel': false,
            'canViewAllHotels': true,
            'canViewOwnHotels': false,
          };
        default:
          return {
            'canCreateHotel': false,
            'canUpdateHotel': false,
            'canDeleteHotel': false,
            'canViewAllHotels': false,
            'canViewOwnHotels': false,
          };
      }
    } catch (e) {
      return {
        'canCreateHotel': false,
        'canUpdateHotel': false,
        'canDeleteHotel': false,
        'canViewAllHotels': false,
        'canViewOwnHotels': false,
      };
    }
  }
}
