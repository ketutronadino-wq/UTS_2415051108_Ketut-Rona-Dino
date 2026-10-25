class SavedRecipeModel {
  final String id;
  final String recipeId;
  final String title;
  final String category;
  final String note;
  final int rating;

  SavedRecipeModel({
    required this.id,
    required this.recipeId,
    required this.title,
    required this.category,
    required this.note,
    required this.rating,
  });

  factory SavedRecipeModel.fromJson(Map<String, dynamic> json) {
    return SavedRecipeModel(
      id: json['id'] ?? '',
      recipeId: json['recipe_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      note: json['note'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}