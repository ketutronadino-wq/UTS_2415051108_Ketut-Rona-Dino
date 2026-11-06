import 'package:flutter/material.dart';
import '../app_keys.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  String _permissionStatus = 'belum diminta';
  String? _token;
  bool _isTokenRegistered = false;
  bool _isStarting = false;
  String _error = '';

  bool get isFirebaseReady => NotificationRepository.isFirebaseReady;
  String get permissionStatus => _permissionStatus;
  String? get token => _token;
  bool get isTokenRegistered => _isTokenRegistered;
  bool get isStarting => _isStarting;
  String get error => _error;
  bool get isPermissionGranted => _permissionStatus == 'authorized' || _permissionStatus == 'provisional';

  Future<void> start() async {
    if (_isStarting || !isFirebaseReady) return;
    _isStarting = true;
    notifyListeners();
    try {
      _permissionStatus = await _repository.requestPermission();
      notifyListeners();
      if (isPermissionGranted) {
        await _repository.enableForegroundPresentation();
        final token = await _repository.getToken();
        _token = token;
        if (token != null) await _registerToken(token);
        _repository.startListening(
          onForeground: (title, body) {
            messengerKey.currentState?.showSnackBar(SnackBar(content: Text(body.isEmpty ? title : '$title\n$body')));
          },
          onTokenRefresh: (newToken) {
            _token = newToken;
            _registerToken(newToken);
          },
        );
      }
    } catch (e) {
      _error = 'Gagal: $e';
    }
    _isStarting = false;
    notifyListeners();
  }

  Future<void> _registerToken(String token) async {
    try {
      await _repository.registerToken(token);
      _isTokenRegistered = true;
    } catch (e) {
      _isTokenRegistered = false;
    }
    notifyListeners();
  }

  Future<void> stop() async {
    _repository.stopListening();
    final token = _token;
    if (token != null && NotificationRepository.isFirebaseReady) {
      try { await _repository.unregisterToken(token); } catch (_) {}
    }
    _token = null;
    _isTokenRegistered = false;
    _permissionStatus = 'belum diminta';
    notifyListeners();
  }

  @override
  void dispose() {
    _repository.stopListening();
    super.dispose();
  }
}