import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/saved_recipe_model.dart';
import '../repositories/recipe_repository.dart';
import '../services/supabase_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();
  final SupabaseService _supabaseService = SupabaseService();

  // State REST API
  bool _isLoading = false;
  List<RecipeModel> _recipes = [];
  String _errorMessage = '';

  // State Database (CRUD)
  List<SavedRecipeModel> _savedRecipes = [];
  bool _isDbLoading = false;

  // Getter
  bool get isLoading => _isLoading;
  List<RecipeModel> get recipes => _recipes;
  String get errorMessage => _errorMessage;
  List<SavedRecipeModel> get savedRecipes => _savedRecipes;
  bool get isDbLoading => _isDbLoading;

  // --- FUNGSI REST API ---
  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _recipes = await _repository.getRecipes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // --- FUNGSI DATABASE (CRUD) ---
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
      await fetchSavedRecipes();
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