import '../models/recipe_model.dart';
import '../services/api_service.dart';

class RecipeRepository {
  final ApiService _apiService = ApiService();

  Future<List<RecipeModel>> getRecipes() async {
    // Di masa depan, kita bisa menambahkan logika (misal: caching) di sini
    return await _apiService.fetchRecipes();
  }
}