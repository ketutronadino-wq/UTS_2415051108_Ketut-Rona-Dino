import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/recipe_provider.dart';
import 'repositories/notification_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationRepository.initializeFirebase();

  await Supabase.initialize(
    url: 'https://udxvdovqkwyjxneujrqw.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkeHZkb3Zxa3d5anhuZXVqcnF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4NjkxNjgsImV4cCI6MjEwODQ0NTE2OH0.t-pZ5uBiTc6wDL1UrrkUn4oVdsIFw0OmNxXjHdoBP7s',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()..fetchRecipes()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const MyApp(),
    ),
  );
}