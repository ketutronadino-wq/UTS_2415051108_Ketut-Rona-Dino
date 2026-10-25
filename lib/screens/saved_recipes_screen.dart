import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/empty_state.dart';
import 'edit_recipe_screen.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchSavedRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Favorit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.fetchSavedRecipes();
            },
          )
        ],
      ),
      body: provider.isDbLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          provider.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => provider.fetchSavedRecipes(),
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : provider.savedRecipes.isEmpty
                  ? const EmptyState(
                      message: 'Belum ada resep yang disimpan.',
                      icon: Icons.favorite_border,
                    )
                  : ListView.builder(
                      itemCount: provider.savedRecipes.length,
                      itemBuilder: (context, index) {
                        final saved = provider.savedRecipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(saved.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Rating: ${saved.rating} ⭐ | Catatan: ${saved.note.isEmpty ? "-" : saved.note}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditRecipeScreen(savedRecipe: saved),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(context, provider, saved.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showDeleteDialog(BuildContext context, RecipeProvider provider, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Resep?'),
          content: const Text('Apakah Anda yakin ingin menghapus resep ini dari favorit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await provider.deleteRecipeFromDb(id);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resep berhasil dihapus.'), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}