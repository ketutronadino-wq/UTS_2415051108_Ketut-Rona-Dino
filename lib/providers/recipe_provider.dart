import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/saved_recipe_model.dart';
import '../repositories/recipe_repository.dart';
import '../services/supabase_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();
  final SupabaseService _supabaseService = SupabaseService();

  // State
  bool _isLoading = false;
  List<RecipeModel> _recipes = [];
  String _errorMessage = '';
  final List<RecipeModel> _savedRecipes = [];

List<SavedRecipeModel> _savedRecipes = [];
  bool _isDbLoading = false;

  // Getter
   bool get isLoading => _isLoading;
  List<RecipeModel> get recipes => _recipes;
  String get errorMessage => _errorMessage;
  List<SavedRecipeModel> get savedRecipes => _savedRecipes;
  bool get isDbLoading => _isDbLoading;

  // Fungsi untuk mengambil data dari API
  Future<void> fetchSavedRecipes() async {
    _isDbLoading = true;
    notifyListeners();
    try {
      _savedRecipes = await _supabaseService.getSavedRecipes();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isDbLoading = false;
    notifyListeners();
  }

  Future<bool> saveRecipeToDb(RecipeModel recipe) async {
    try {
      await _supabaseService.addSavedRecipe(
        recipeId: recipe.id,
        title: recipe.name,
        category: recipe.category,
      );
      await fetchSavedRecipes(); // Refresh list setelah simpan
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRecipeInDb(String id, String note, int rating) async {
    try {
      await _supabaseService.updateSavedRecipe(id: id, note: note, rating: rating);
      await fetchSavedRecipes();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRecipeFromDb(String id) async {
    try {
      await _supabaseService.deleteSavedRecipe(id);
      await fetchSavedRecipes();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

  // Fungsi sementara untuk Shared State Favorite (Akan dimodifikasi di Hari 8-10)
  void toggleFavorite(RecipeModel recipe) {
    if (_savedRecipes.contains(recipe)) {
      _savedRecipes.remove(recipe);
    } else {
      _savedRecipes.add(recipe);
    }
    notifyListeners();
  }
}