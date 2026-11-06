import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;
  String? get currentUserEmail => _client.auth.currentUser?.email;
  bool get isLoggedIn => _client.auth.currentSession != null;

  Stream<String?> get userIdChanges => _client.auth.onAuthStateChange
      .map((state) => state.session?.user.id)
      .distinct();

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return response.session != null;
    } on AuthException catch (e) {
      throw Exception(_translate(e.message));
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw Exception(_translate(e.message));
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(_translate(e.message));
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    }
  }

  String _translate(String message) {
    final text = message.toLowerCase();
    if (text.contains('invalid login credentials')) return 'Email atau password salah.';
    if (text.contains('already registered')) return 'Email sudah terdaftar. Silakan login.';
    if (text.contains('email not confirmed')) return 'Email belum dikonfirmasi.';
    if (text.contains('password should be at least')) return 'Password terlalu pendek (minimal 6 karakter).';
    if (text.contains('rate limit')) return 'Terlalu banyak percobaan. Coba lagi.';
    if (text.contains('socketexception') || text.contains('clientexception')) return 'Tidak ada koneksi internet.';
    return message;
  }
}