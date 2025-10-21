import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';
import '../services/sembast_service.dart';

// Supabase service provider
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

// Sembast service provider
final sembastServiceProvider = Provider<SembastService>((ref) {
  return SembastService();
});
