import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../viewmodels/auth_bloc.dart';
import '../viewmodels/auth_state.dart';
import '../viewmodels/auth_event.dart';
import '../models/authenticated_user.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Utility class for easy access to authentication features
class AuthUtils {
  /// Check if user is currently authenticated
  static bool isAuthenticated(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated;
  }
  
  /// Get current user if authenticated
  static AuthenticatedUser? getCurrentUser(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      return state.user;
    }
    return null;
  }
  
  /// Navigate to login page if not authenticated
  static void requireAuth(BuildContext context) {
    if (!isAuthenticated(context)) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
  
  /// Sign out the current user
  static void signOut(BuildContext context) {
    context.read<AuthBloc>().add(AuthSignOutRequested());
  }
    /// Get authentication token from storage
  static Future<String?> getToken() async {
    return await StorageService().getToken();
  }
  
  /// Get headers with authentication token for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    return await StorageService().getAuthHeaders();
  }
  
  /// Get all user information from JWT token
  static Future<Map<String, dynamic>?> getUserInfoFromToken() async {
    return await AuthService().getUserInfo();
  }
}
