import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/local_recipe_model.dart';
import '../providers/auth_provider.dart';
import '../providers/local_recipe_provider.dart';
import '../providers/recipe_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';

/// Form TAMBAH (recipe == null) dan EDIT (recipe != null) resep komunitas.
/// Khusus admin: tampilan dijaga di sini, dan database menolak non-admin (RLS).
class LocalRecipeFormScreen extends StatefulWidget {
  final LocalRecipeModel? recipe;

  const LocalRecipeFormScreen({super.key, this.recipe});

  @override
  State<LocalRecipeFormScreen> createState() => _LocalRecipeFormScreenState();
}

class _LocalRecipeFormScreenState extends State<LocalRecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _categoryController;
  late final TextEditingController _thumbnailController;
  late final TextEditingController _ingredientsController;
  late final TextEditingController _instructionsController;

  bool get _isEdit => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    _titleController = TextEditingController(text: recipe?.title ?? '');
    _categoryController = TextEditingController(text: recipe?.category ?? '');
    _thumbnailController = TextEditingController(text: recipe?.thumbnail ?? '');
    _ingredientsController =
        TextEditingController(text: recipe?.ingredients ?? '');
    _instructionsController =
        TextEditingController(text: recipe?.instructions ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _thumbnailController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<LocalRecipeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final bool success;
    if (_isEdit) {
      success = await provider.update(
        widget.recipe!.id,
        title: _titleController.text,
        category: _categoryController.text,
        instructions: _instructionsController.text,
        ingredients: _ingredientsController.text,
        thumbnail: _thumbnailController.text,
      );
    } else {
      success = await provider.add(
        title: _titleController.text,
        category: _categoryController.text,
        instructions: _instructionsController.text,
        ingredients: _ingredientsController.text,
        thumbnail: _thumbnailController.text,
      );
    }

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(success
            ? (_isEdit
                ? 'Resep berhasil diperbarui!'
                : 'Resep berhasil ditambahkan!')
            : 'Gagal menyimpan: ${provider.actionError}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthProvider, bool>((auth) => auth.isAdmin);
    final isSaving = context.watch<LocalRecipeProvider>().isSaving;
    final suggestions = context.read<RecipeProvider>().categories;
    final title = _isEdit ? 'Edit Resep Komunitas' : 'Tambah Resep Komunitas';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const EmptyState(
          message: 'Halaman ini khusus admin.',
          icon: Icons.lock_outline,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          // Scrollable agar tidak overflow saat keyboard muncul
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    enabled: !isSaving,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama Resep',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.minLength(value, 'Nama resep', 3),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    enabled: !isSaving,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      hintText: 'Contoh: Dessert',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => Validators.notEmpty(value, 'Kategori'),
                  ),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: suggestions
                          .map(
                            (category) => ActionChip(
                              label: Text(category),
                              visualDensity: VisualDensity.compact,
                              onPressed: isSaving
                                  ? null
                                  : () => setState(
                                      () => _categoryController.text = category),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _thumbnailController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'URL Gambar (opsional)',
                      hintText: 'https://...',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.optionalUrl,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ingredientsController,
                    enabled: !isSaving,
                    minLines: 3,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Bahan (opsional)',
                      hintText: 'Satu bahan per baris',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _instructionsController,
                    enabled: !isSaving,
                    minLines: 5,
                    maxLines: 12,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText: 'Instruksi Memasak',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.minLength(value, 'Instruksi', 10),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _isEdit ? 'Simpan Perubahan' : 'Simpan Resep',
                    icon: Icons.save,
                    isLoading: isSaving,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
