import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import 'recipe_detail_screen.dart'; // Pastikan file ini dibuat di langkah selanjutnya

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DATA DUMMY UNTUK SEMENTARA
    final dummyRecipes = List.generate(10, (index) => {
      'id': '$index',
      'title': 'Resep Makanan ${index + 1}',
      'category': 'Kategori ${index % 3 == 0 ? 'Makanan' : 'Minuman'}',
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Semua Resep')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // RESPONSIVE: Jika lebar > 600 (Tablet/Landscape), pakai Grid
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: dummyRecipes.length,
              itemBuilder: (context, index) {
                final recipe = dummyRecipes[index];
                return CustomCard(
                  title: recipe['title']!,
                  subtitle: recipe['category']!,
                  onTap: () => _goToDetail(context, recipe['title']!),
                );
              },
            );
          } else {
            // RESPONSIVE: Jika HP (Compact), pakai List
            return ListView.builder(
              itemCount: dummyRecipes.length,
              itemBuilder: (context, index) {
                final recipe = dummyRecipes[index];
                return CustomCard(
                  title: recipe['title']!,
                  subtitle: recipe['category']!,
                  onTap: () => _goToDetail(context, recipe['title']!),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Fungsi Passing Data ke Detail
  void _goToDetail(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipeTitle: title),
      ),
    );
  }
}