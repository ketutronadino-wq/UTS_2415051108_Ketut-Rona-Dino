import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'edit_recipe_screen.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resep Favorit'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: provider.fetchSavedRecipes,
          ),
        ],
      ),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, RecipeProvider provider) {
    // 1. Loading state
    if (provider.isDbLoading && provider.savedRecipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error state
    if (provider.dbError.isNotEmpty && provider.savedRecipes.isEmpty) {
      return ErrorState(
        message: provider.dbError,
        onRetry: provider.fetchSavedRecipes,
      );
    }

    // 3. Empty state
    if (provider.savedRecipes.isEmpty) {
      return const EmptyState(
        message: 'Belum ada resep yang disimpan.\nBuka detail resep lalu tekan "Simpan ke Favorit".',
        icon: Icons.favorite_border,
      );
    }

    // 4. Data (responsive: compact = list, wide = grid)
    final items = provider.savedRecipes;
    return RefreshIndicator(
      onRefresh: provider.fetchSavedRecipes,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 700) {
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 520,
                mainAxisExtent: 110,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) => _buildItem(
                context,
                provider,
                items[index],
                inGrid: true,
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: items.length,
            itemBuilder: (context, index) =>
                _buildItem(context, provider, items[index]),
          );
        },
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    RecipeProvider provider,
    SavedRecipeModel saved, {
    bool inGrid = false,
  }) {
    final note = saved.note.isEmpty ? '-' : saved.note;

    return CustomCard(
      title: saved.title,
      subtitle: '${saved.category}  •  ⭐ ${saved.rating}/5\nCatatan: $note',
      isThreeLine: true,
      margin: inGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFE0B2),
        child: Icon(Icons.favorite, color: Colors.red),
      ),
      onTap: () => _goToEdit(context, saved),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _goToEdit(context, saved),
          ),
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, provider, saved),
          ),
        ],
      ),
    );
  }

  void _goToEdit(BuildContext context, SavedRecipeModel saved) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditRecipeScreen(savedRecipe: saved)),
    );
  }

  // DELETE dengan dialog konfirmasi
  void _showDeleteDialog(
    BuildContext context,
    RecipeProvider provider,
    SavedRecipeModel saved,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep?'),
          content: Text('Hapus "${saved.title}" dari favorit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final success = await provider.deleteSavedRecipe(saved.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Resep berhasil dihapus.'
                        : 'Gagal menghapus: ${provider.actionError}'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}