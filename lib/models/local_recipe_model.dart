import 'recipe_model.dart';

class LocalRecipeModel {
  final String id;
  final String createdBy;
  final String title;
  final String category;
  final String instructions;
  final String ingredients; 
  final String thumbnail;
  final DateTime? createdAt;

  const LocalRecipeModel({
    required this.id,
    this.createdBy = '',
    required this.title,
    required this.category,
    required this.instructions,
    this.ingredients = '',
    required this.thumbnail,
    this.createdAt,
  });

  factory LocalRecipeModel.fromJson(Map<String, dynamic> json) {
    return LocalRecipeModel(
      id: (json['id'] ?? '').toString(),
      createdBy: (json['created_by'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      instructions: (json['instructions'] ?? '').toString(),
      ingredients: (json['ingredients'] ?? '').toString(),
      thumbnail: (json['thumbnail'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }

  List<String> get ingredientList => ingredients
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  RecipeModel toRecipeModel() {
    return RecipeModel(
      id: id,
      name: title,
      category: category,
      area: 'Komunitas',
      instructions: instructions.trim().isEmpty ? 'Belum ada instruksi.' : instructions,
      thumbnail: thumbnail,
      ingredients: ingredientList,
    );
  }
}