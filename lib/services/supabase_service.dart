import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_recipe_model.dart';
import 'database_guard.dart';

class SupabaseService {
  static const String _table = 'saved_recipes';
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw Exception('Sesi berakhir. Silakan login ulang.');
    return id;
  }

  Future<List<SavedRecipeModel>> getSavedRecipes() {
    return guardDatabase(() async {
      final rows = await _client
          .from(_table)
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);
      return rows.map((row) => SavedRecipeModel.fromJson(row)).toList();
    });
  }

  Future<List<SavedRecipeModel>> getAllSavedRecipes() {
    return guardDatabase(() async {
      final rows = await _client.from(_table).select().order('created_at', ascending: false);
      return rows.map((row) => SavedRecipeModel.fromJson(row)).toList();
    });
  }

  Future<SavedRecipeModel> addSavedRecipe({
    required String recipeId,
    required String title,
    required String category,
    String note = '',
    int rating = 0,
  }) {
    return guardDatabase(() async {
      final row = await _client
          .from(_table)
          .insert({
            'user_id': _userId,
            'recipe_id': recipeId,
            'title': title,
            'category': category,
            'note': note,
            'rating': rating,
          })
          .select()
          .single();
      return SavedRecipeModel.fromJson(row);
    });
  }

  Future<SavedRecipeModel> updateSavedRecipe({
    required String id,
    required String note,
    required int rating,
  }) {
    return guardDatabase(() async {
      final rows = await _client
          .from(_table)
          .update({'note': note, 'rating': rating})
          .eq('id', id)
          .select();
      if (rows.isEmpty) {
        throw Exception('Operasi ditolak: data bukan milik Anda atau tidak ditemukan.');
      }
      return SavedRecipeModel.fromJson(rows.first);
    });
  }

  Future<void> deleteSavedRecipe(String id) {
    return guardDatabase(() async {
      final rows = await _client.from(_table).delete().eq('id', id).select();
      if (rows.isEmpty) {
        throw Exception('Operasi ditolak: data bukan milik Anda atau tidak ditemukan.');
      }
    });
  }
}