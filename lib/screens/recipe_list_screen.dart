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
  String _searchQuery = ''; // State untuk menyimpan kata kunci pencarian

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipeProvider>(context);

    // Filter data berdasarkan pencarian
    final filteredRecipes = provider.recipes.where((recipe) {
      return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Resep'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

          // Jika hasil filter kosong (Empty State)
          if (filteredRecipes.isEmpty) {
            return EmptyState(
              message: _searchQuery.isEmpty 
                  ? 'Tidak ada resep ditemukan.' 
                  : 'Resep "$_searchQuery" tidak ditemukan.',
              icon: Icons.search_off,
            );
          }

          // Tampilkan Data (Responsive)
          if (constraints.maxWidth > 600) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
                return CustomCard(
                  title: recipe.name,
                  subtitle: recipe.category,
                  leading: Image.network(recipe.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                  onTap: () => _goToDetail(context, recipe),
                );
              },
            );
          } else {
            return ListView.builder(
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];
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

  void _goToDetail(BuildContext context, dynamic recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }
}