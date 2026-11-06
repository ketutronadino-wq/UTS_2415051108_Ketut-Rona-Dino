import 'package:flutter_test/flutter_test.dart';
import 'package:uts_recipebox/models/recipe_model.dart';
import 'package:uts_recipebox/models/saved_recipe_model.dart';

void main() {
  group('RecipeModel.fromJson', () {
    test('memetakan field dan menggabungkan bahan + takaran', () {
      final recipe = RecipeModel.fromJson({
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions': 'Preheat oven to 350 F.',
        'strMealThumb': 'https://example.com/teriyaki.jpg',
        'strIngredient1': 'soy sauce',
        'strMeasure1': '3/4 cup',
        'strIngredient2': 'water',
        'strMeasure2': '',
        'strIngredient3': '',
        'strMeasure3': '',
      });

      expect(recipe.id, '52772');
      expect(recipe.name, 'Teriyaki Chicken Casserole');
      expect(recipe.category, 'Chicken');
      expect(recipe.area, 'Japanese');
      expect(recipe.thumbnail, 'https://example.com/teriyaki.jpg');
      expect(recipe.ingredients, ['3/4 cup soy sauce', 'water']);
    });

    test('memakai nilai default saat data null/kosong (null safety)', () {
      final recipe = RecipeModel.fromJson({});

      expect(recipe.id, '');
      expect(recipe.name, 'No Name');
      expect(recipe.category, 'Unknown');
      expect(recipe.thumbnail, '');
      expect(recipe.ingredients, isEmpty);
    });
  });

  group('SavedRecipeModel.fromJson', () {
    test('memetakan field dari tabel saved_recipes', () {
      final saved = SavedRecipeModel.fromJson({
        'id': 7, // integer pun harus aman
        'recipe_id': '52772',
        'title': 'Teriyaki Chicken Casserole',
        'category': 'Chicken',
        'note': null,
        'rating': 4,
        'created_at': '2026-10-26T10:00:00Z',
      });

      expect(saved.id, '7');
      expect(saved.recipeId, '52772');
      expect(saved.note, '');
      expect(saved.rating, 4);
      expect(saved.createdAt, isNotNull);
    });
  });
}