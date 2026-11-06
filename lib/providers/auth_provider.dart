import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

enum RegisterResult { signedIn, needsConfirmation, failed }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  StreamSubscription<String?>? _subscription;

  String? _userId;
  String? _email;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _isProfileLoading = false;
  String _error = '';
  String _profileError = '';

  AuthProvider() {
    _userId = _repository.currentUserId;
    _email = _repository.currentUserEmail;
    if (_userId != null) loadProfile();
    _subscription = _repository.userIdChanges.listen(_onUserChanged);
  }

  String? get userId => _userId;
  String? get userEmail => _email;
  bool get isLoggedIn => _userId != null;
  UserProfile? get profile => _profile;
  String get role => _profile?.role ?? 'user';
  bool get isAdmin => role == 'admin';
  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;
  String get error => _error;
  String get profileError => _profileError;

  String get displayName {
    final name = _profile?.name.trim() ?? '';
    if (name.isNotEmpty) return name;
    return _profile?.email ?? _email ?? 'Pengguna';
  }

  String _cleanError(Object error) => error.toString().replaceFirst('Exception: ', '');

  void _onUserChanged(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _email = _repository.currentUserEmail;
    _profile = null;
    _isProfileLoading = false;
    notifyListeners();
    if (userId != null) loadProfile();
  }

  Future<void> loadProfile() async {
    final requestedFor = _userId;
    if (requestedFor == null) return;
    _isProfileLoading = true;
    notifyListeners();
    try {
      final profile = await _repository.getMyProfile();
      if (_userId != requestedFor) return;
      _profile = profile;
    } catch (e) {
      if (_userId != requestedFor) return;
      _profileError = _cleanError(e);
    }
    _isProfileLoading = false;
    notifyListeners();
  }

  Future<RegisterResult> register({required String name, required String email, required String password}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final hasSession = await _repository.register(email: email, password: password, name: name);
      _isLoading = false;
      notifyListeners();
      return hasSession ? RegisterResult.signedIn : RegisterResult.needsConfirmation;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return RegisterResult.failed;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      await _repository.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await _repository.logout();
      return true;
    } catch (e) {
      _error = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}