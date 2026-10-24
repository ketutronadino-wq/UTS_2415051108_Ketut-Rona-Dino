import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class EditRecipeScreen extends StatelessWidget {
  const EditRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Catatan Resep')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Catatan Memasak',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Simpan Perubahan',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}