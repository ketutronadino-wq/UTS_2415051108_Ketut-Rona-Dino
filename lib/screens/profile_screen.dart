import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 16),
            Text('Nama Mahasiswa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('NIM: 231011234'),
            Text('Kelas: Pemrograman Mobile'),
            SizedBox(height: 20),
            Text('Aplikasi RecipeBox - Project UTS'),
          ],
        ),
      ),
    );
  }
}