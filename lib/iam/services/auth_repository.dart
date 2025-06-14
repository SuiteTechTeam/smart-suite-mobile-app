import '../models/sign_up_request.dart';
import '../models/sign_in_request.dart';
import '../models/authenticated_user.dart';
import '../models/user_role.dart';
import '../services/auth_api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required AuthApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;
  Future<AuthenticatedUser> signIn(String email, String password, UserRole role) async {
    final request = SignInRequest(
      email: email,
      password: password,
      roleId: role.id,
    );

    print('AuthRepository: Attempting sign-in for $email with role ${role.name}');
    
    try {
      // Try the normal sign-in first
      final authenticatedUserFromApi = await _apiService.signIn(request);
      
      // El backend no retorna roleId ni role, así que los agregamos manualmente
      final authenticatedUser = AuthenticatedUser(
        id: authenticatedUserFromApi.id,
        email: authenticatedUserFromApi.email,
        token: authenticatedUserFromApi.token,
        roleId: role.id,
        role: role.name,
      );
      await _storageService.saveAuthenticatedUser(authenticatedUser);
      print('AuthRepository: Sign-in successful');
      return authenticatedUser;
    } catch (e) {
      print('AuthRepository: Primary sign-in failed: $e');
      
      // Try the fallback method
      try {
        print('AuthRepository: Trying fallback sign-in method...');
        final authenticatedUserFromApi = await _apiService.signInWithFallback(request);
        
        final authenticatedUser = AuthenticatedUser(
          id: authenticatedUserFromApi.id,
          email: authenticatedUserFromApi.email,
          token: authenticatedUserFromApi.token,
          roleId: role.id,
          role: role.name,
        );
        await _storageService.saveAuthenticatedUser(authenticatedUser);
        print('AuthRepository: Fallback sign-in successful');
        return authenticatedUser;
      } catch (fallbackError) {
        print('AuthRepository: Fallback sign-in also failed: $fallbackError');
        rethrow; // Re-throw the original error
      }    }
  }

  Future<void> signUp(String name, String surname, String phone, String email, String password, UserRole role) async {
    final request = SignUpRequest(
      name: name,
      surname: surname,
      phone: phone,
      email: email,
      password: password,
    );

    switch (role) {
      case UserRole.admin:
        await _apiService.signUpAdmin(request);
        break;
      case UserRole.guest:
        await _apiService.signUpGuest(request);
        break;
      case UserRole.owner:
        await _apiService.signUpOwner(request);
        break;
    }
  }

  Future<void> signOut() async {
    await _storageService.clearAuthenticatedUser();
  }

  Future<AuthenticatedUser?> getCurrentUser() async {
    return await _storageService.getAuthenticatedUser();
  }

  Future<bool> isAuthenticated() async {
    return await _storageService.isAuthenticated();
  }

  Future<String?> getToken() async {
    return await _storageService.getToken();
  }

  Future<Map<String, String>> getAuthHeaders() async {
    return await _storageService.getAuthHeaders();
  }
}
