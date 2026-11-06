import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/custom_button.dart';
import 'admin_screen.dart';

const String _nama = 'Ketut Rona Dino'; // GANTI DENGAN NAMA ANDA
const String _nim = '2415051108';       // GANTI DENGAN NIM ANDA
const String _kelas = 'Pemrograman Mobile';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifications = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(radius: 60, backgroundColor: Colors.orange, child: Icon(Icons.person, size: 80, color: Colors.white)),
                const SizedBox(height: 20),
                const Text(_nama, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('NIM: $_nim', style: const TextStyle(color: Colors.grey)),
                Text('Kelas: $_kelas', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.badge, color: Colors.orange),
                    title: Text('Role: ${auth.role}'),
                    subtitle: Text('Email: ${auth.userEmail ?? "-"}'),
                    trailing: auth.isProfileLoading ? const CircularProgressIndicator() : IconButton(icon: const Icon(Icons.refresh), onPressed: auth.loadProfile),
                  ),
                ),
                if (auth.isAdmin)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                      title: const Text('Kelola Semua Favorit'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen())),
                    ),
                  ),
                const SizedBox(height: 16),
                CustomButton(text: 'Logout', icon: Icons.logout, color: Colors.red, onPressed: () => _logout(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}