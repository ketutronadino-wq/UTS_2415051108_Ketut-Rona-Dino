import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_keys.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/local_recipe_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/recipe_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/saved_recipes_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeBox UTS',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Check Session: belum login -> LoginScreen, sudah login -> aplikasi utama.
/// Juga menyiapkan / membersihkan data milik user setiap status login berubah.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _handledUserId;

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String?>((auth) => auth.userId);

    if (userId != _handledUserId) {
      _handledUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) => _onUserChanged(userId));
    }

    return userId == null ? const LoginScreen() : const MainNavigationScreen();
  }

  void _onUserChanged(String? userId) {
    if (!mounted) return;

    final recipes = context.read<RecipeProvider>();
    final notifications = context.read<NotificationProvider>();
    final admin = context.read<AdminProvider>();
    final localRecipes = context.read<LocalRecipeProvider>();

    if (userId == null) {
      // Logout / session berakhir: tutup halaman yang masih terbuka
      // dan bersihkan semua data milik user sebelumnya.
      Navigator.of(context).popUntil((route) => route.isFirst);
      recipes.clearUserData();
      admin.clear();
      localRecipes.clear();
      notifications.stop();
    } else {
      // Login: muat favorit milik user ini dan siapkan push notification.
      recipes.clearUserData();
      recipes.fetchSavedRecipes();
      localRecipes.fetchAll();
      notifications.start();
    }
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.icon, this.selectedIcon, this.label);
}

const List<_NavItem> _navItems = [
  _NavItem(Icons.home_outlined, Icons.home, 'Home'),
  _NavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu, 'Resep'),
  _NavItem(Icons.favorite_border, Icons.favorite, 'Favorit'),
  _NavItem(Icons.person_outline, Icons.person, 'Profil'),
];

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _selectTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    // IndexedStack menjaga state tiap tab (teks pencarian, posisi scroll)
    final body = IndexedStack(
      index: _currentIndex,
      children: [
        HomeScreen(onSeeAllRecipes: () => _selectTab(1)),
        const RecipeListScreen(),
        const SavedRecipesScreen(),
        const ProfileScreen(),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Layout wide/expanded: NavigationRail di sisi kiri
        if (constraints.maxWidth >= 720) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _selectTab,
                  labelType: NavigationRailLabelType.all,
                  destinations: _navItems
                      .map((item) => NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: Text(item.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        // Layout compact: NavigationBar di bawah
        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _selectTab,
            destinations: _navItems
                .map((item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
