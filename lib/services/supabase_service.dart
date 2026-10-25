import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_recipe_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // READ
  Future<List<SavedRecipeModel>> getSavedRecipes() async {
    final response = await _client
        .from('saved_recipes')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => SavedRecipeModel.fromJson(json)).toList();
  }

  // CREATE
  Future<void> addSavedRecipe({
    required String recipeId,
    required String title,
    required String category,
  }) async {
    await _client.from('saved_recipes').insert({
      'recipe_id': recipeId,
      'title': title,
      'category': category,
      'note': '',
      'rating': 0,
    });
  }

  // UPDATE
  Future<void> updateSavedRecipe({
    required String id,
    required String note,
    required int rating,
  }) async {
    await _client.from('saved_recipes').update({
      'note': note,
      'rating': rating,
    }).eq('id', id);
  }

  // DELETE
  Future<void> deleteSavedRecipe(String id) async {
    await _client.from('saved_recipes').delete().eq('id', id);
  }
}