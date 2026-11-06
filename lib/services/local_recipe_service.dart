import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/local_recipe_model.dart';
import 'database_guard.dart';

class LocalRecipeService {
  static const String _table = 'recipes';
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Sesi berakhir. Silakan login ulang.');
    return id;
  }

  Future<List<LocalRecipeModel>> getAll() {
    return guardDatabase(() async {
      final rows = await _client.from(_table).select().order('created_at', ascending: false);
      return rows.map((row) => LocalRecipeModel.fromJson(row)).toList();
    });
  }

  Future<LocalRecipeModel> add({
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) {
    return guardDatabase(() async {
      final row = await _client.from(_table).insert({
        'created_by': _userId, 'title': title, 'category': category,
        'instructions': instructions, 'ingredients': ingredients, 'thumbnail': thumbnail,
      }).select().single();
      return LocalRecipeModel.fromJson(row);
    });
  }

  Future<LocalRecipeModel> update(String id, {
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) {
    return guardDatabase(() async {
      final rows = await _client.from(_table).update({
        'title': title, 'category': category, 'instructions': instructions,
        'ingredients': ingredients, 'thumbnail': thumbnail,
      }).eq('id', id).select();
      if (rows.isEmpty) throw Exception('Operasi ditolak: hanya admin yang dapat mengubah resep komunitas.');
      return LocalRecipeModel.fromJson(rows.first);
    });
  }

  Future<void> delete(String id) {
    return guardDatabase(() async {
      final rows = await _client.from(_table).delete().eq('id', id).select();
      if (rows.isEmpty) throw Exception('Operasi ditolak: hanya admin yang dapat menghapus resep komunitas.');
    });
  }
}