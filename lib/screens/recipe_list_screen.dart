import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_recipe_model.dart';
import '../models/recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/local_recipe_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/recipe_image.dart';
import '../widgets/role_guard.dart';
import 'local_recipe_form_screen.dart';
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

  /// Gabungan kategori resep API + resep komunitas (tanpa duplikat).
  List<String> _mergeCategories(List<String> api, List<String> local) {
    final seen = <String>{};
    final result = <String>[];
    for (final category in [...api, ...local]) {
      if (seen.add(category.toLowerCase())) result.add(category);
    }
    result.sort();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final local = context.watch<LocalRecipeProvider>();
    final auth = context.watch<AuthProvider>();
    final categories = _mergeCategories(provider.categories, local.categories);

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
      // Tombol tambah resep hanya untuk admin
      floatingActionButton: RoleGuard(
        role: auth.role,
        allowed: const ['admin'],
        child: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Resep Baru'),
        ),
      ),
      body: Column(
        children: [
          if (categories.isNotEmpty) _buildCategoryFilter(provider, categories),
          Expanded(child: _buildContent(provider, local, auth)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(RecipeProvider provider, List<String> categories) {
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
          ...categories.map(
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

  Widget _buildContent(
    RecipeProvider provider,
    LocalRecipeProvider local,
    AuthProvider auth,
  ) {
    // 1. Loading state
    if (provider.isLoading && provider.recipes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error state
    if (provider.apiError.isNotEmpty && provider.recipes.isEmpty) {
      return ErrorState(
        message: provider.apiError,
        onRetry: () {
          provider.fetchRecipes(force: true);
          local.fetchAll();
        },
      );
    }

    final apiRecipes = provider.filteredRecipes;
    final localRecipes = local.filtered(
      query: provider.searchQuery,
      category: provider.selectedCategory,
    );
    final showLocalError = local.error.isNotEmpty && local.recipes.isEmpty;

    // 3. Empty state
    if (apiRecipes.isEmpty && localRecipes.isEmpty && !showLocalError) {
      return EmptyState(
        message: provider.hasActiveFilter
            ? 'Resep tidak ditemukan dengan filter saat ini.'
            : 'Tidak ada resep ditemukan.',
        icon: Icons.search_off,
        actionLabel: provider.hasActiveFilter ? 'Reset Filter' : null,
        onAction: provider.hasActiveFilter ? provider.clearFilters : null,
      );
    }

    final showAdminHint = auth.isAdmin &&
        local.recipes.isEmpty &&
        !local.isLoading &&
        local.error.isEmpty &&
        !provider.hasActiveFilter;

    // 4. Data: dua bagian (Komunitas di atas, Publik di bawah),
    //    responsif: compact = list, wide = grid
    return RefreshIndicator(
      onRefresh: () => _refresh(provider, local),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (showLocalError)
                SliverToBoxAdapter(child: _buildLocalError(local)),
              if (showAdminHint)
                const SliverToBoxAdapter(child: _AdminHint()),
              if (localRecipes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.groups,
                    title: 'Resep Komunitas',
                    count: localRecipes.length,
                  ),
                ),
                _recipeSliver(
                  localRecipes.length,
                  isWide,
                  (index) => _buildLocalCard(
                    localRecipes[index],
                    isAdmin: auth.isAdmin,
                    inGrid: isWide,
                  ),
                ),
              ],
              if (apiRecipes.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    icon: Icons.public,
                    title: 'Resep Publik (TheMealDB)',
                    count: apiRecipes.length,
                  ),
                ),
                _recipeSliver(
                  apiRecipes.length,
                  isWide,
                  (index) => _buildCard(apiRecipes[index], inGrid: isWide),
                ),
              ],
              // ruang agar item terakhir tidak tertutup tombol "Resep Baru"
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
      ),
    );
  }

  Widget _recipeSliver(
    int count,
    bool isWide,
    Widget Function(int index) itemBuilder,
  ) {
    if (isWide) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 450,
            mainAxisExtent: 92,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => itemBuilder(index),
            childCount: count,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => itemBuilder(index),
        childCount: count,
      ),
    );
  }

  Widget _buildLocalError(LocalRecipeProvider local) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.warning_amber, color: Colors.red),
        title: const Text('Resep komunitas gagal dimuat'),
        subtitle: Text(local.error),
        trailing: TextButton(
          onPressed: local.fetchAll,
          child: const Text('Coba lagi'),
        ),
      ),
    );
  }

  // Kartu resep publik (API)
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

  // Kartu resep komunitas: tombol edit/hapus hanya untuk admin
  Widget _buildLocalCard(
    LocalRecipeModel recipe, {
    required bool isAdmin,
    bool inGrid = false,
  }) {
    return CustomCard(
      title: recipe.title,
      subtitle: '${recipe.category} • Komunitas',
      margin: inGrid
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: RecipeImage(url: recipe.thumbnail, width: 50, height: 50),
      trailing: isAdmin
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _openForm(recipe),
                ),
                IconButton(
                  tooltip: 'Hapus',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(recipe),
                ),
              ],
            )
          : null,
      onTap: () => _goToDetail(recipe.toRecipeModel()),
    );
  }

  Future<void> _refresh(
    RecipeProvider provider,
    LocalRecipeProvider local,
  ) async {
    await Future.wait([
      provider.fetchRecipes(force: true),
      local.fetchAll(),
    ]);
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

  void _openForm([LocalRecipeModel? recipe]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LocalRecipeFormScreen(recipe: recipe),
      ),
    );
  }

  // DELETE dengan dialog konfirmasi
  void _confirmDelete(LocalRecipeModel recipe) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep?'),
          content: Text(
              'Hapus "${recipe.title}" dari Resep Komunitas? Tindakan ini tidak dapat dibatalkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final local = context.read<LocalRecipeProvider>();
                final success = await local.delete(recipe.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Resep berhasil dihapus.'
                        : 'Gagal menghapus: ${local.actionError}'),
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Text('$count', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _AdminHint extends StatelessWidget {
  const _AdminHint();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: Icon(Icons.info_outline, color: Colors.blue),
        title: Text('Belum ada resep komunitas'),
        subtitle: Text('Tekan tombol "Resep Baru" untuk menambahkan resep pertama.'),
      ),
    );
  }
}
