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

    final authenticatedUser = await _apiService.signIn(request);
    await _storageService.saveAuthenticatedUser(authenticatedUser);
    
    return authenticatedUser;
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
