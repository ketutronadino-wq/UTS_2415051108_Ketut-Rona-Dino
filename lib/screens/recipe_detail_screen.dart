import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../widgets/custom_button.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView( // Gunakan scroll agar tidak overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(recipe.thumbnail, width: double.infinity, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(recipe.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Kategori: ${recipe.category} | Asal: ${recipe.area}'),
            const SizedBox(height: 16),
            const Text('Instruksi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(recipe.instructions),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Simpan ke Favorit',
              onPressed: () {
                // Nanti dihubungkan ke Database
              },
            )
          ],
        ),
      ),
    );
  }
}