import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeTitle;

  const RecipeDetailScreen({super.key, required this.recipeTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Resep')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipeTitle, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Ini adalah deskripsi instruksi memasak. Nanti data ini diambil dari REST API.'),
            const Spacer(),
            CustomButton(
              text: 'Simpan ke Favorit',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}