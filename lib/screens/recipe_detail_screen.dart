import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan gambar
            Image.network(
              recipe.thumbnail,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50)),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(recipe.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Kategori: ${recipe.category} | Asal: ${recipe.area}'),
            const SizedBox(height: 16),
            const Text('Instruksi:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(recipe.instructions),
            const SizedBox(height: 24),
            
            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  // Tampilkan loading dialog sementara
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // Panggil fungsi database
                    final success = await context.read<RecipeProvider>().saveRecipeToDb(recipe);
                    
                    // Tutup loading dialog
                    if (!context.mounted) return;
                    Navigator.pop(context);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resep berhasil disimpan ke Favorit!'), 
                          backgroundColor: Colors.green
                        ),
                      );
                    } else {
                      throw Exception("Gagal menyimpan ke database.");
                    }
                  } catch (e) {
                    // Jika error, tutup dialog dan tampilkan pesan
                    if (!context.mounted) return;
                    Navigator.pop(context); 
                    
                    // CETAK ERROR KE TERMINAL (untuk debugging)
                    debugPrint("ERROR SIMPAN DATABASE: $e");
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal: ${e.toString()}'), 
                        backgroundColor: Colors.red
                      ),
                    );
                  }
                },
                child: const Text(
                  'Simpan ke Favorit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}