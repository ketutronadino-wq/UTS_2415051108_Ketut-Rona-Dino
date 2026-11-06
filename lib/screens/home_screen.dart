import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/error_state.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  /// Dipanggil untuk pindah ke tab "Resep" pada navigasi utama.
  final VoidCallback onSeeAllRecipes;

  const HomeScreen({super.key, required this.onSeeAllRecipes});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('RecipeBox Dashboard')),
      body: Center(
        // Di layar lebar, konten dibatasi agar tidak melebar berlebihan
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang di RecipeBox!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Temukan resep favoritmu hari ini dan simpan catatan memasakmu.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pencarian cepat
              _QuickSearchField(
                onSubmitted: (query) {
                  provider.setFilters(query: query.trim());
                  onSeeAllRecipes();
                },
              ),
              const SizedBox(height: 16),

              // Ringkasan
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.restaurant_menu,
                      label: 'Resep tersedia',
                      value: '${provider.recipes.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.favorite,
                      label: 'Favoritmu',
                      value: '${provider.savedRecipes.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomButton(
                text: 'Lihat Semua Resep',
                icon: Icons.restaurant_menu,
                onPressed: () {
                  provider.clearFilters();
                  onSeeAllRecipes();
                },
              ),
              const SizedBox(height: 24),

              // Kategori (diambil dari data API, tap = filter di tab Resep)
              if (provider.categories.isNotEmpty) ...[
                const Text('Kategori',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: provider.categories
                      .map(
                        (category) => ActionChip(
                          label: Text(category),
                          backgroundColor: Colors.orange.shade100,
                          onPressed: () {
                            provider.setFilters(category: category);
                            onSeeAllRecipes();
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Rekomendasi
              Row(
                children: [
                  const Expanded(
                    child: Text('Rekomendasi Resep',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      onSeeAllRecipes();
                    },
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildRecommended(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommended(BuildContext context, RecipeProvider provider) {
    if (provider.isLoading && provider.recipes.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.apiError.isNotEmpty && provider.recipes.isEmpty) {
      return ErrorState(
        message: provider.apiError,
        onRetry: () => provider.fetchRecipes(force: true),
      );
    }

    final recommended = provider.recommendedRecipes;
    if (recommended.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Belum ada rekomendasi resep.')),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommended.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final recipe = recommended[index];
          return _RecommendedCard(
            recipe: recipe,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(recipe: recipe),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickSearchField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;

  const _QuickSearchField({required this.onSubmitted});

  @override
  State<_QuickSearchField> createState() => _QuickSearchFieldState();
}

class _QuickSearchFieldState extends State<_QuickSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari resep favoritmu...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
      ),
      onSubmitted: (value) {
        widget.onSubmitted(value);
        _controller.clear();
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onTap;

  const _RecommendedCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipeImage(
                url: recipe.thumbnail,
                width: double.infinity,
                height: 110,
                borderRadius: 0,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}