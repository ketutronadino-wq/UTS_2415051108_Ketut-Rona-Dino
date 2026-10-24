import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resep Favorit')),
      body: const EmptyState(
        message: 'Belum ada resep yang disimpan.',
        icon: Icons.favorite_border,
      ),
    );
  }
}