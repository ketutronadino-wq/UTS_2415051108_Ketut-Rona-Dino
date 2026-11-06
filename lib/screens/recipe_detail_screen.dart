import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../models/saved_recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/recipe_image.dart';
import 'add_recipe_screen.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final saved = provider.savedRecipeFor(recipe.id);

    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final actionButton = _buildActionButton(context, saved);

          // Layout wide: gambar + tombol di kiri, informasi di kanan
          if (constraints.maxWidth >= 700) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        RecipeImage(
                          url: recipe.thumbnail,
                          width: double.infinity,
                          height: 320,
                          borderRadius: 16,
                        ),
                        const SizedBox(height: 16),
                        actionButton,
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    child: _buildInfo(context, saved),
                  ),
                ),
              ],
            );
          }

          // Layout compact: semua ditumpuk vertikal
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RecipeImage(
                  url: recipe.thumbnail,
                  width: double.infinity,
                  height: 220,
                  borderRadius: 16,
                ),
                const SizedBox(height: 16),
                _buildInfo(context, saved),
                const SizedBox(height: 24),
                actionButton,
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(BuildContext context, SavedRecipeModel? saved) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(recipe.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(
              avatar: const Icon(Icons.category, size: 18),
              label: Text(recipe.category),
            ),
            Chip(
              avatar: const Icon(Icons.public, size: 18),
              label: Text(recipe.area),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Catatan pribadi (tampil jika resep sudah disimpan)
        if (saved != null) ...[
          Card(
            margin: EdgeInsets.zero,
            color: scheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text('Ada di Favorit  •  ⭐ ${saved.rating}/5',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (saved.note.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Catatanmu: ${saved.note}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (recipe.ingredients.isNotEmpty) ...[
          const Text('Bahan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...recipe.ingredients.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• $item'),
            ),
          ),
          const SizedBox(height: 16),
        ],

        const Text('Instruksi:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(recipe.instructions),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, SavedRecipeModel? saved) {
    // Sudah disimpan -> edit catatan. Belum -> buka form tambah (Create).
    if (saved != null) {
      return CustomButton(
        text: 'Edit Catatan & Rating',
        icon: Icons.edit,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditRecipeScreen(savedRecipe: saved),
          ),
        ),
      );
    }

    return CustomButton(
      text: 'Simpan ke Favorit',
      icon: Icons.favorite_border,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddRecipeScreen(recipe: recipe)),
      ),
    );
  }
}