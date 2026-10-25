import 'package:flutter/material.dart';
import 'recipe_list_screen.dart'; // Import screen list

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RecipeBox Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selamat Datang di RecipeBox!', 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text('Temukan resep favoritmu hari ini dan simpan catatan memasakmu.', 
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tombol CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepOrange,
                elevation: 2,
                side: const BorderSide(color: Colors.deepOrange),
              ),
              onPressed: () {
                // Arahkan ke tab List (Menggunakan Navigator langsung ke screen, 
                // meskipun tabnya ada di bawah, ini adalah cara cepatnya)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecipeListScreen()),
                );
              },
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Lihat Semua Resep', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),

          // Kategori Cepat
          const Text('Kategori Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              Chip(label: const Text('Makanan Utama'), backgroundColor: Colors.orange.shade100),
              Chip(label: const Text('Minuman'), backgroundColor: Colors.orange.shade100),
              Chip(label: const Text('Camilan'), backgroundColor: Colors.orange.shade100),
              Chip(label: const Text('Penutup'), backgroundColor: Colors.orange.shade100),
            ],
          )
        ],
      ),
    );
  }
}