import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/config/supabase_config.dart';
import 'app/app.dart';
import 'core/di/injection.dart';

/// Main entry point for Maharat application
/// 
/// Initializes all required services and dependencies before
/// launching the application. Follows enterprise-grade patterns
/// for application bootstrapping.
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI appearance
  await _configureSystemUI();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Initialize dependency injection
  await configureDependencies();

  // Run the application
  runApp(const MaharatApp());
}

/// Configures system-level UI settings
/// 
/// Sets up preferred orientations and status bar appearance
/// for a polished, professional look.
Future<void> _configureSystemUI() async {
  // Lock to portrait orientation for consistent UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure transparent status bar with dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}
