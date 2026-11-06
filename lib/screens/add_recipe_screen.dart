import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_input.dart';
import '../widgets/recipe_image.dart';

/// Screen CREATE: form untuk menyimpan resep ke favorit (database).
class AddRecipeScreen extends StatefulWidget {
  final RecipeModel recipe;

  const AddRecipeScreen({super.key, required this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  int _rating = 0;
  bool _showRatingError = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isFormValid = _formKey.currentState!.validate();
    if (_rating == 0) setState(() => _showRatingError = true);
    if (!isFormValid || _rating == 0) return;

    final provider = context.read<RecipeProvider>();
    final success = await provider.saveRecipe(
      widget.recipe,
      note: _noteController.text,
      rating: _rating,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Resep berhasil disimpan ke Favorit!'
            : 'Gagal menyimpan: ${provider.actionError}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<RecipeProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Simpan ke Favorit')),
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
                  Row(
                    children: [
                      RecipeImage(
                        url: widget.recipe.thumbnail,
                        width: 72,
                        height: 72,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(widget.recipe.category),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Form dengan validation
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Memasak',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: Kurangi gula, masak 20 menit',
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Catatan tidak boleh kosong!';
                      if (text.length < 3) return 'Catatan minimal 3 karakter.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  const Text('Rating:'),
                  RatingInput(
                    value: _rating,
                    onChanged: (value) => setState(() {
                      _rating = value;
                      _showRatingError = false;
                    }),
                  ),
                  if (_showRatingError)
                    Text(
                      'Pilih rating minimal 1 bintang.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 24),

                  CustomButton(
                    text: 'Simpan',
                    icon: Icons.favorite,
                    isLoading: isSaving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}