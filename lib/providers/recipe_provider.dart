import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../repositories/recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository = RecipeRepository();

  // State
  bool _isLoading = false;
  List<RecipeModel> _recipes = [];
  String _errorMessage = '';
  final List<RecipeModel> _savedRecipes = [];

  // Getter
  bool get isLoading => _isLoading;
  List<RecipeModel> get recipes => _recipes;
  String get errorMessage => _errorMessage;
  List<RecipeModel> get savedRecipes => _savedRecipes;

  // Fungsi untuk mengambil data dari API
  Future<void> fetchRecipes() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners(); // Beritahu UI kalau loading mulai

    try {
      _recipes = await _repository.getRecipes();
      _isLoading = false;
      notifyListeners(); // Beritahu UI kalau data sudah siap
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners(); // Beritahu UI kalau ada error
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