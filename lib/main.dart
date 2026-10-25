import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/recipe_provider.dart';
import 'screens/home_screen.dart';
import 'screens/recipe_list_screen.dart';
import 'screens/saved_recipes_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://udxvdovqkwyjxneujrqw.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkeHZkb3Zxa3d5anhuZXVqcnF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4NjkxNjgsImV4cCI6MjEwODQ0NTE2OH0.t-pZ5uBiTc6wDL1UrrkUn4oVdsIFw0OmNxXjHdoBP7s',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => RecipeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RecipeBox UTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecipeListScreen(),
    const SavedRecipesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      // Perhatikan struktur NavigationBar di bawah ini, sudah rapi.
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          // Jika user pindah ke tab Favorit (index 2), panggil ulang datanya
          if (index == 2) {
            context.read<RecipeProvider>().fetchSavedRecipes();
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Resep'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorit'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}