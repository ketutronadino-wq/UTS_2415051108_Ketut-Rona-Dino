import '../models/recipe_model.dart';
import '../models/saved_recipe_model.dart';
import '../services/supabase_service.dart';

class SavedRecipeRepository {
  final SupabaseService _service = SupabaseService();

  Future<List<SavedRecipeModel>> getSavedRecipes() => _service.getSavedRecipes();
  Future<List<SavedRecipeModel>> getAllSavedRecipes() => _service.getAllSavedRecipes();

  Future<SavedRecipeModel> addSavedRecipe(RecipeModel recipe, {required String note, required int rating}) {
    return _service.addSavedRecipe(
      recipeId: recipe.id,
      title: recipe.name,
      category: recipe.category,
      note: note.trim(),
      rating: rating,
    );
  }

  Future<SavedRecipeModel> updateSavedRecipe({required String id, required String note, required int rating}) {
    return _service.updateSavedRecipe(id: id, note: note.trim(), rating: rating);
  }

  Future<void> deleteSavedRecipe(String id) => _service.deleteSavedRecipe(id);
}