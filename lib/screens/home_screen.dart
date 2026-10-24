import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RecipeBox Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat Datang di RecipeBox!', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text('Temukan resep favoritmu hari ini.', 
                  style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Kategori Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: const Text('Makanan Utama'), backgroundColor: Colors.orange.shade100),
              Chip(label: const Text('Minuman'), backgroundColor: Colors.orange.shade100),
              Chip(label: const Text('Camilan'), backgroundColor: Colors.orange.shade100),
            ],
          )
        ],
      ),
    );
  }
}