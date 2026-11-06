import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import 'database_guard.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> getMyProfile() {
    return guardDatabase(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();
      return data == null ? null : UserProfile.fromMap(data);
    });
  }

  Future<Map<String, String>> getEmailsByUserId() {
    return guardDatabase(() async {
      final rows = await _client.from('profiles').select('id, email');
      return {
        for (final row in rows)
          (row['id'] ?? '').toString(): (row['email'] ?? '').toString(),
      };
    });
  }
}