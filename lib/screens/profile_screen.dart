import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // Nama dan NIM
              const Text(
                'Nama Mahasiswa', // GANTI DENGAN NAMA ANDA
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                'NIM: 231011234', // GANTI DENGAN NIM ANDA
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Text(
                'Kelas: Pemrograman Mobile',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Card Info Aplikasi
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tentang Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('RecipeBox adalah aplikasi pencarian resep makanan yang mengintegrasikan REST API TheMealDB dan Database Supabase untuk menyimpan resep favorit.'),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
  children: [
    Icon(Icons.code, color: Colors.orange),
    const SizedBox(width: 8),
    // BUNGKUS DENGAN EXPANDED
    const Expanded( 
      child: Text(
        'Dibuat untuk Project UTS Pemrograman Mobile',
        // Tambahkan softWrap agar teks turun ke bawah jika tidak muat
        softWrap: true, 
      ),
    ),
  ],
)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}