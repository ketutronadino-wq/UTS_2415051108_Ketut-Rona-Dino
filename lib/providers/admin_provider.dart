import 'package:flutter/material.dart';
import '../models/saved_recipe_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/saved_recipe_repository.dart';

class AdminProvider extends ChangeNotifier {
  final SavedRecipeRepository _savedRepository = SavedRecipeRepository();
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String _error = '';
  String _actionError = '';
  List<SavedRecipeModel> _items = [];
  Map<String, String> _emails = {};

  bool get isLoading => _isLoading;
  String get error => _error;
  String get actionError => _actionError;
  List<SavedRecipeModel> get items => _items;

  String ownerLabel(SavedRecipeModel item) => _emails[item.userId] ?? 'user ${item.userId.substring(0, 8)}';

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      _items = await _savedRepository.getAllSavedRecipes();
      _emails = await _authRepository.getUserEmails();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> delete(String id) async {
    try {
      await _savedRepository.deleteSavedRecipe(id);
      _items.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _actionError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _items = [];
    _emails = {};
    notifyListeners();
  }
}