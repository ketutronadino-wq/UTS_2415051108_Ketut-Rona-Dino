import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/role_guard.dart';
import 'admin_screen.dart';
import 'local_recipe_form_screen.dart';

const String _nama = 'Ketut Rona Dino';
const String _nim = '2415051108';
const String _kelas = 'Pendidikan Teknik Informatika 5A';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final notifications = context.read<NotificationProvider>();
    final auth = context.read<AuthProvider>();

    // Hapus token perangkat selagi masih login, baru signOut
    await notifications.stop();
    final success = await auth.logout();

    // Jika sukses, AuthGate sudah kembali ke Login (context tidak mounted)
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifications = context.watch<NotificationProvider>();
    final profile = auth.profile;

    final accountName =
        (profile?.name ?? '').isEmpty ? '-' : profile!.name;
    final accountEmail = profile?.email ?? auth.userEmail ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  _nama,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  'NIM: $_nim',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Text(
                  'Kelas: $_kelas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // ---------- Akun (currentUser + role) ----------
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Akun',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              tooltip: 'Muat ulang profil',
                              icon: const Icon(Icons.refresh),
                              onPressed: auth.isProfileLoading
                                  ? null
                                  : auth.loadProfile,
                            ),
                          ],
                        ),
                        if (auth.isProfileLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: LinearProgressIndicator(),
                          ),
                        if (auth.profileError.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(auth.profileError,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        _InfoRow(icon: Icons.person, text: 'Nama: $accountName'),
                        _InfoRow(icon: Icons.email, text: 'Email: $accountEmail'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.badge,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text('Role: '),
                              Chip(
                                visualDensity: VisualDensity.compact,
                                label: Text(auth.role),
                                backgroundColor: auth.isAdmin
                                    ? Colors.red.shade100
                                    : Colors.orange.shade100,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Fitur khusus admin ----------
                RoleGuard(
                  role: auth.role,
                  allowed: const ['admin'],
                  child: Column(
                    children: [
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.admin_panel_settings,
                                  color: Colors.red),
                              title: const Text('Kelola Semua Favorit'),
                              subtitle: const Text(
                                  'Khusus admin: lihat & hapus data semua pengguna'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AdminScreen()),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.library_add,
                                  color: Colors.blue),
                              title: const Text('Tambah Resep Komunitas'),
                              subtitle: const Text(
                                  'Khusus admin: resep baru tampil di tab Resep'),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const LocalRecipeFormScreen()),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ---------- Notifikasi (FCM) ----------
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifikasi (FCM)',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (!notifications.isFirebaseReady)
                          const Text(
                              'Firebase belum dikonfigurasi. Jalankan "flutterfire configure" lalu jalankan ulang aplikasi.')
                        else ...[
                          _InfoRow(
                              icon: Icons.notifications_active,
                              text: 'Izin: ${notifications.permissionStatus}'),
                          _InfoRow(
                              icon: Icons.cloud_done,
                              text:
                                  'Terdaftar di server: ${notifications.isTokenRegistered ? 'ya' : 'belum'}'),
                          if (!notifications.isPermissionGranted)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: notifications.isStarting
                                    ? null
                                    : notifications.start,
                                icon: const Icon(Icons.notifications),
                                label: const Text('Aktifkan notifikasi'),
                              ),
                            ),
                          if (notifications.token != null) ...[
                            const SizedBox(height: 8),
                            const Text('FCM Token:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            SelectableText(
                              notifications.token!,
                              style: const TextStyle(fontSize: 11),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: notifications.token!));
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Token disalin')),
                                  );
                                },
                                icon: const Icon(Icons.copy, size: 18),
                                label: const Text('Salin token'),
                              ),
                            ),
                          ],
                        ],
                        if (notifications.error.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(notifications.error,
                                style: const TextStyle(color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ---------- Tentang aplikasi ----------
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tentang Aplikasi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          'RecipeBox adalah aplikasi pencarian resep yang mengintegrasikan REST API TheMealDB, autentikasi dan database Supabase (dengan Row Level Security), serta push notification Firebase.',
                        ),
                        SizedBox(height: 16),
                        Divider(),
                        SizedBox(height: 8),
                        _InfoRow(icon: Icons.cloud, text: 'REST API: TheMealDB'),
                        _InfoRow(
                            icon: Icons.storage,
                            text: 'Backend: Supabase (Auth + PostgreSQL + RLS)'),
                        _InfoRow(
                            icon: Icons.layers,
                            text: 'State management: Provider + ChangeNotifier'),
                        _InfoRow(
                            icon: Icons.code,
                            text: 'Dibuat untuk Project UTS & Worksheet 9 Pemrograman Mobile'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Logout',
                  icon: Icons.logout,
                  color: Colors.red,
                  onPressed: () => _logout(context),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          // Expanded + teks yang bisa turun baris -> tidak overflow
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
