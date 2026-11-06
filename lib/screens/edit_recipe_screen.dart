import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/rating_input.dart';

/// Screen UPDATE: ubah catatan dan rating resep favorit.
class EditRecipeScreen extends StatefulWidget {
  final SavedRecipeModel savedRecipe;

  const EditRecipeScreen({super.key, required this.savedRecipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;
  late int _rating;
  bool _showRatingError = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.savedRecipe.note);
    _rating = widget.savedRecipe.rating;
  }

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
    final success = await provider.updateSavedRecipe(
      id: widget.savedRecipe.id,
      note: _noteController.text,
      rating: _rating,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Catatan berhasil diperbarui!'
            : 'Gagal memperbarui: ${provider.actionError}'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<RecipeProvider>().isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Catatan Resep')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          // Scrollable agar tidak RenderFlex overflow saat keyboard muncul
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.savedRecipe.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Catatan Memasak',
                      border: OutlineInputBorder(),
                      hintText: 'Contoh: Tambahkan sedikit garam',
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
                    text: 'Simpan Perubahan',
                    icon: Icons.save,
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
