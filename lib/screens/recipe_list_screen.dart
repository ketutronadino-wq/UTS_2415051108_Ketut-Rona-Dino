import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late final RecipeProvider _provider;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _provider = context.read<RecipeProvider>();
    _searchController = TextEditingController(text: _provider.searchQuery);
    // Sinkronkan teks kolom cari jika filter diubah dari screen lain (Home)
    _provider.addListener(_syncSearchText);
  }

  void _syncSearchText() {
    if (_searchController.text != _provider.searchQuery) {
      _searchController.text = _provider.searchQuery;
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_syncSearchText);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Resep'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Cari resep...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => provider.setSearchQuery(''),
                      ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (provider.categories.isNotEmpty) _buildCategoryFilter(provider),
          Expanded(child: _buildContent(provider)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(RecipeProvider provider) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Semua'),
              selected: provider.selectedCategory == null,
              onSelected: (_) => provider.setCategory(null),
            ),
          ),
          ...provider.categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: provider.selectedCategory == category,
                onSelected: (_) => provider.setCategory(category),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RecipeProvider provider) {
    // 1. Loading state
    if (provider.isLoading && provider.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error state
    if (provider.apiError.isNotEmpty && provider.recipes.isEmpty) {
      return ErrorState(
        message: provider.apiError,
        onRetry: () => provider.fetchRecipes(force: true),
      );
    }

    // 3. Empty state
    final recipes = provider.filteredRecipes;
    if (recipes.isEmpty) {
      return EmptyState(
        message: provider.hasActiveFilter
            ? 'Resep tidak ditemukan dengan filter saat ini.'
            : 'Tidak ada resep ditemukan.',
        icon: Icons.search_off,
        actionLabel: provider.hasActiveFilter ? 'Reset Filter' : null,
        onAction: provider.hasActiveFilter ? provider.clearFilters : null,
      );
    }

    // 4. Data (responsive: compact = list, wide = grid)
    return RefreshIndicator(
      onRefresh: () => _refresh(provider),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 450,
                mainAxisExtent: 92,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: recipes.length,
              itemBuilder: (context, index) =>
                  _buildCard(recipes[index], inGrid: true),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: recipes.length,
            itemBuilder: (context, index) => _buildCard(recipes[index]),
          );
        },
      ),
    );
  }

  Widget _buildCard(RecipeModel recipe, {bool inGrid = false}) {
    return CustomCard(
      title: recipe.name,
      subtitle: '${recipe.category} • ${recipe.area}',
      margin: inGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: RecipeImage(url: recipe.thumbnail, width: 50, height: 50),
      onTap: () => _goToDetail(recipe),
    );
  }

  Future<void> _refresh(RecipeProvider provider) async {
    await provider.fetchRecipes(force: true);
    if (!mounted || provider.apiError.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.apiError), backgroundColor: Colors.red),
    );
  }

  void _goToDetail(RecipeModel recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
    );
  }
}