class RecipeModel {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final List<String> ingredients;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    this.ingredients = const [],
  });

  // Konversi dari JSON (API) ke Dart Object
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    // TheMealDB menyimpan bahan sebagai strIngredient1..20 dan strMeasure1..20
    final ingredients = <String>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = (json['strIngredient$i'] ?? '').toString().trim();
      final measure = (json['strMeasure$i'] ?? '').toString().trim();
      if (ingredient.isNotEmpty) {
        ingredients.add(measure.isEmpty ? ingredient : '$measure $ingredient');
      }
    }

    return RecipeModel(
      id: (json['idMeal'] ?? '').toString(),
      name: (json['strMeal'] ?? 'No Name').toString(),
      category: (json['strCategory'] ?? 'Unknown').toString(),
      area: (json['strArea'] ?? 'Unknown').toString(),
      instructions:
          (json['strInstructions'] ?? 'No instructions provided.').toString(),
      thumbnail: (json['strMealThumb'] ?? '').toString(),
      ingredients: ingredients,
    );
  }
}