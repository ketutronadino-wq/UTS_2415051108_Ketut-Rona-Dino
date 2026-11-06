import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../models/saved_recipe_model.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/saved_recipe_repository.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _recipeRepository = RecipeRepository();
  final SavedRecipeRepository _savedRepository = SavedRecipeRepository();

  bool _isLoading = false;
  List<RecipeModel> _recipes = [];
  String _apiError = '';
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isDbLoading = false;
  bool _isSaving = false;
  List<SavedRecipeModel> _savedRecipes = [];
  String _dbError = '';
  String _actionError = '';

  bool get isLoading => _isLoading;
  List<RecipeModel> get recipes => _recipes;
  String get apiError => _apiError;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get hasActiveFilter => _searchQuery.trim().isNotEmpty || _selectedCategory != null;
  bool get isDbLoading => _isDbLoading;
  bool get isSaving => _isSaving;
  List<SavedRecipeModel> get savedRecipes => _savedRecipes;
  String get dbError => _dbError;
  String get actionError => _actionError;

  List<RecipeModel> get filteredRecipes {
    final query = _searchQuery.trim().toLowerCase();
    return _recipes.where((recipe) {
      final matchName = query.isEmpty || recipe.name.toLowerCase().contains(query);
      final matchCategory = _selectedCategory == null || recipe.category == _selectedCategory;
      return matchName && matchCategory;
    }).toList();
  }

  List<String> get categories {
    final result = _recipes.map((r) => r.category).where((c) => c.isNotEmpty).toSet().toList();
    result.sort();
    return result;
  }

  List<RecipeModel> get recommendedRecipes => _recipes.take(6).toList();
  bool isSaved(String recipeId) => _savedRecipes.any((s) => s.recipeId == recipeId);
  SavedRecipeModel? savedRecipeFor(String recipeId) {
    for (final saved in _savedRecipes) { if (saved.recipeId == recipeId) return saved; }
    return null;
  }

  String _cleanError(Object error) => error.toString().replaceFirst('Exception: ', '');

  void setSearchQuery(String value) { _searchQuery = value; notifyListeners(); }
  void setCategory(String? category) { _selectedCategory = category; notifyListeners(); }
  void setFilters({String query = '', String? category}) { _searchQuery = query; _selectedCategory = category; notifyListeners(); }
  void clearFilters() => setFilters();

  Future<void> fetchRecipes({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _recipes.isNotEmpty) return;
    _isLoading = true;
    _apiError = '';
    notifyListeners();
    try {
      _recipes = await _recipeRepository.getRecipes();
    } catch (e) {
      _apiError = _cleanError(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSavedRecipes() async {
    _isDbLoading = true;
    _dbError = '';
    notifyListeners();
    try {
      _savedRecipes = await _savedRepository.getSavedRecipes();
    } catch (e) {
      _dbError = _cleanError(e);
    }
    _isDbLoading = false;
    notifyListeners();
  }

  Future<bool> saveRecipe(RecipeModel recipe, {required String note, required int rating}) async {
    _isSaving = true;
    _actionError = '';
    notifyListeners();
    try {
      final saved = await _savedRepository.addSavedRecipe(recipe, note: note, rating: rating);
      _savedRecipes = [saved, ..._savedRecipes];
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = _cleanError(e);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSavedRecipe({required String id, required String note, required int rating}) async {
    _isSaving = true;
    _actionError = '';
    notifyListeners();
    try {
      final updated = await _savedRepository.updateSavedRecipe(id: id, note: note, rating: rating);
      final index = _savedRecipes.indexWhere((s) => s.id == id);
      if (index != -1) _savedRecipes[index] = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = _cleanError(e);
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSavedRecipe(String id) async {
    _actionError = '';
    try {
      await _savedRepository.deleteSavedRecipe(id);
      _savedRecipes.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  void clearUserData() {
    _savedRecipes = [];
    _dbError = '';
    _actionError = '';
    _isDbLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}