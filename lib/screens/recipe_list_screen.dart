import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil API saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Semua Resep')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 1. Cek Loading State
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Cek Error State
          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 10),
                  Text(provider.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchRecipes(),
                    child: const Text('Coba Lagi'),
                  )
                ],
              ),
            );
          }

          // 3. Cek Empty State
          if (provider.recipes.isEmpty) {
            return const EmptyState(
              message: 'Tidak ada resep ditemukan.',
              icon: Icons.search_off,
            );
          }

          // 4. Tampilkan Data
          if (constraints.maxWidth > 600) {
            // GridView (Tablet/Landscape)
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: provider.recipes.length,
              itemBuilder: (context, index) {
                final recipe = provider.recipes[index];
                return CustomCard(
                  title: recipe.name,
                  subtitle: recipe.category,
                  leading: Image.network(recipe.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                  onTap: () => _goToDetail(context, recipe),
                );
              },
            );
          } else {
            // ListView (HP)
            return ListView.builder(
              itemCount: provider.recipes.length,
              itemBuilder: (context, index) {
                final recipe = provider.recipes[index];
                return CustomCard(
                  title: recipe.name,
                  subtitle: recipe.category,
                  leading: Image.network(recipe.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                  onTap: () => _goToDetail(context, recipe),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Passing data objek utuh ke Detail
  void _goToDetail(BuildContext context, dynamic recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}