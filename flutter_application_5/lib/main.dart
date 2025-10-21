import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/simple_home_screen.dart';
import 'constants/app_colors.dart';
import 'config/env_config.dart';
import 'services/supabase_service.dart';
import 'services/sembast_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment variables (optional - fallback if not available)
  try {
    await dotenv.load(fileName: ".env");
    EnvConfig.validate();
    debugPrint('✅ Environment variables loaded');
  } catch (e) {
    debugPrint('⚠️ .env file not found or invalid: $e');
  }
  
  // Initialize Supabase (optional - app works without it)
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase initialized');
  } catch (e) {
    debugPrint('⚠️ Supabase initialization failed: $e');
  }
  
  // Initialize local storage
  try {
    await SembastService.initialize();
    debugPrint('✅ Local storage initialized');
  } catch (e) {
    debugPrint('⚠️ Local storage initialization failed: $e');
  }
  
  runApp(const ProviderScope(child: GhorerBazarApp()));
}

class GhorerBazarApp extends ConsumerWidget {
  const GhorerBazarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ghorer Bazar - ঘরের বাজার',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: authState.when(
        data: (state) {
          // Always show home screen, but auth affects features
          return const HomeScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => const HomeScreen(), // Show home even if auth fails
      ),
    );
  }
}
