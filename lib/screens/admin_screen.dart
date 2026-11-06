import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/admin_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Semua Favorit'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: admin.fetchAll)],
      ),
      body: admin.isLoading && admin.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : admin.error.isNotEmpty && admin.items.isEmpty
              ? ErrorState(message: admin.error, onRetry: admin.fetchAll)
              : admin.items.isEmpty
                  ? const EmptyState(message: 'Belum ada data favorit.', icon: Icons.favorite_border)
                  : ListView.builder(
                      itemCount: admin.items.length,
                      itemBuilder: (context, index) {
                        final item = admin.items[index];
                        return CustomCard(
                          title: item.title,
                          subtitle: 'Pemilik: ${admin.ownerLabel(item)}',
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(admin, item),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showDeleteDialog(AdminProvider admin, SavedRecipeModel item) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Favorit?'),
        content: Text('Hapus "${item.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await admin.delete(item.id);
              if (!mounted) return;
              if (success) context.read<RecipeProvider>().fetchSavedRecipes();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(success ? 'Favorit dihapus.' : 'Gagal: ${admin.actionError}'),
                backgroundColor: success ? Colors.green : Colors.red,
              ));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}