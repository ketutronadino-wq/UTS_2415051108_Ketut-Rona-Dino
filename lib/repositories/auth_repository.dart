import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String? get currentUserId => _authService.currentUserId;
  String? get currentUserEmail => _authService.currentUserEmail;
  Stream<String?> get userIdChanges => _authService.userIdChanges;

  Future<bool> register({required String email, required String password, required String name}) {
    return _authService.register(email: email, password: password, name: name);
  }

  Future<void> login({required String email, required String password}) {
    return _authService.login(email: email, password: password);
  }

  Future<void> logout() => _authService.logout();
  Future<UserProfile?> getMyProfile() => _profileService.getMyProfile();
  Future<Map<String, String>> getUserEmails() => _profileService.getEmailsByUserId();
}