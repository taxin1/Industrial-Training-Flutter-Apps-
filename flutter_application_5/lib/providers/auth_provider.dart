import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});

// Sign in state notifier
class SignInNotifier extends StateNotifier<AsyncValue<void>> {
  SignInNotifier(this._authService) : super(const AsyncValue.data(null));
  
  final AuthService _authService;
  
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _authService.signIn(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final signInProvider = StateNotifierProvider<SignInNotifier, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignInNotifier(authService);
});

// Sign up state notifier
class SignUpNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  SignUpNotifier(this._authService) : super(const AsyncValue.data(null));
  
  final AuthService _authService;
  
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        address: address,
      );
      state = AsyncValue.data(response);
      return response;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, AsyncValue<AuthResponse?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignUpNotifier(authService);
});
