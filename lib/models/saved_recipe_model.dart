class SavedRecipeModel {
  final String id;
  final String userId;
  final String recipeId;
  final String title;
  final String category;
  final String note;
  final int rating;
  final DateTime? createdAt;

  const SavedRecipeModel({
    required this.id,
    this.userId = '',
    required this.recipeId,
    required this.title,
    required this.category,
    required this.note,
    required this.rating,
    this.createdAt,
  });

  factory SavedRecipeModel.fromJson(Map<String, dynamic> json) {
    return SavedRecipeModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      recipeId: (json['recipe_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}