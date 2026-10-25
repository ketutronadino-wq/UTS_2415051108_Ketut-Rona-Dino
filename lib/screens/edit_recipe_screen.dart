import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_recipe_model.dart';
import '../providers/recipe_provider.dart';
import '../widgets/custom_button.dart';

class EditRecipeScreen extends StatefulWidget {
  // PERHATIKAN BARIS INI: Namanya harus savedRecipe
  final SavedRecipeModel savedRecipe; 

  const EditRecipeScreen({super.key, required this.savedRecipe});

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noteController;
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    // Menggunakan widget.savedRecipe
    _noteController = TextEditingController(text: widget.savedRecipe.note);
    _currentRating = widget.savedRecipe.rating;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Catatan Resep')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Judul: ${widget.savedRecipe.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Form Catatan dengan Validation
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Memasak',
                  border: OutlineInputBorder(),
                  hintText: 'Contoh: Tambahkan sedikit garam',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Catatan tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Input Rating
              const Text('Rating:'),
              Slider(
                value: _currentRating.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _currentRating.toString(),
                onChanged: (value) {
                  setState(() {
                    _currentRating = value.toInt();
                  });
                },
              ),
              Text('$_currentRating Bintang', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),

              // Tombol Simpan (Update)
              CustomButton(
                text: 'Simpan Perubahan',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await context.read<RecipeProvider>().updateRecipeInDb(
                      widget.savedRecipe.id,
                      _noteController.text,
                      _currentRating,
                    );

                    if (!context.mounted) return;
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan berhasil diperbarui!'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(context); 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal memperbarui catatan.'), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}