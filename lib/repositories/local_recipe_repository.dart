import '../models/local_recipe_model.dart';
import '../services/local_recipe_service.dart';

class LocalRecipeRepository {
  final LocalRecipeService _service = LocalRecipeService();

  Future<List<LocalRecipeModel>> getAll() => _service.getAll();

  Future<LocalRecipeModel> add({
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) {
    return _service.add(
      title: title.trim(), category: category.trim(),
      instructions: instructions.trim(), ingredients: ingredients.trim(),
      thumbnail: thumbnail.trim(),
    );
  }

  Future<LocalRecipeModel> update(String id, {
    required String title, required String category, required String instructions,
    required String ingredients, required String thumbnail,
  }) {
    return _service.update(id,
      title: title.trim(), category: category.trim(),
      instructions: instructions.trim(), ingredients: ingredients.trim(),
      thumbnail: thumbnail.trim(),
    );
  }

  Future<void> delete(String id) => _service.delete(id);
}