import 'package:flutter/material.dart';
import '../models/local_recipe_model.dart';
import '../repositories/local_recipe_repository.dart';

class LocalRecipeProvider extends ChangeNotifier {
  final LocalRecipeRepository _repository = LocalRecipeRepository();

  List<LocalRecipeModel> _recipes = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String _error = '';
  String _actionError = '';
  int _epoch = 0;

  List<LocalRecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get error => _error;
  String get actionError => _actionError;

  String _cleanError(Object error) => error.toString().replaceFirst('Exception: ', '');

  List<String> get categories {
    final result = _recipes.map((recipe) => recipe.category).where((category) => category.isNotEmpty).toSet().toList();
    result.sort();
    return result;
  }

  List<LocalRecipeModel> filtered({String query = '', String? category}) {
    final q = query.trim().toLowerCase();
    final selected = category?.toLowerCase();
    return _recipes.where((recipe) {
      final matchName = q.isEmpty || recipe.title.toLowerCase().contains(q);
      final matchCategory = selected == null || recipe.category.toLowerCase() == selected;
      return matchName && matchCategory;
    }).toList();
  }

  Future<void> fetchAll() async {
    final epoch = _epoch;
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final result = await _repository.getAll();
      if (epoch != _epoch) return;
      _recipes = result;
    } catch (e) {
      if (epoch != _epoch) return;
      _error = _cleanError(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add({
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) async {
    _isSaving = true;
    _actionError = '';
    notifyListeners();
    try {
      final created = await _repository.add(
        title: title, category: category, instructions: instructions,
        ingredients: ingredients, thumbnail: thumbnail,
      );
      _recipes = [created, ..._recipes];
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

  Future<bool> update(String id, {
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) async {
    _isSaving = true;
    _actionError = '';
    notifyListeners();
    try {
      final updated = await _repository.update(id,
        title: title, category: category, instructions: instructions,
        ingredients: ingredients, thumbnail: thumbnail,
      );
      final index = _recipes.indexWhere((recipe) => recipe.id == id);
      if (index != -1) _recipes[index] = updated;
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

  Future<bool> delete(String id) async {
    _actionError = '';
    try {
      await _repository.delete(id);
      _recipes.removeWhere((recipe) => recipe.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = _cleanError(e);
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _epoch++;
    _recipes = [];
    _error = '';
    _actionError = '';
    _isLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}