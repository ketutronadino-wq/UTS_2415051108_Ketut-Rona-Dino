import '../models/recipe_model.dart';
import '../services/api_service.dart';

/// Sumber data katalog resep (REST API).
class RecipeRepository {
  final ApiService _apiService = ApiService();

  Future<List<RecipeModel>> getRecipes() async {
    // Di masa depan bisa ditambah logika lain di sini (misal: caching)
    return _apiService.fetchRecipes();
  }
}
