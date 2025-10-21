import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  // Sign up new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      print('🔵 Starting sign up process for: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'address': address,
        },
      );
      
      print('🔵 Auth response: User ID: ${response.user?.id}');
      print('🔵 Session exists: ${response.session != null}');
      print('🔵 Email confirmed: ${response.user?.emailConfirmedAt != null}');
      
      if (response.user != null) {
        final userId = response.user!.id;
        print('🟢 User created in auth.users with ID: $userId');
        
        // If there's an active session, try to create profile directly
        if (response.session != null) {
          print('🔵 Active session detected - creating profile directly');
          
          // Wait a moment for trigger to complete
          await Future.delayed(const Duration(milliseconds: 1500));
          
          try {
            // Check if profile exists
            final existingProfile = await _supabase
                .from('user_profiles')
                .select('id')
                .eq('id', userId)
                .maybeSingle();
            
            if (existingProfile != null) {
              print('✅ Profile already exists (created by trigger)');
            } else {
              print('⚠️ Profile not found - creating manually');
              
              // Create profile manually as fallback
              await _supabase.from('user_profiles').insert({
                'id': userId,
                'email': email,
                'full_name': fullName,
                'phone_number': phoneNumber,
                'address': address,
                'created_at': DateTime.now().toIso8601String(),
              });
              
              print('✅ Profile created manually');
            }
          } catch (profileError) {
            print('❌ Profile creation error: $profileError');
            // Don't throw - user is created, profile can be created later
          }
        } else {
          print('⚠️ No active session - email confirmation required');
          print('📧 Profile will be created after email confirmation');
        }
      }
      
      return response;
    } catch (e) {
      print('❌ Sign up failed with error: $e');
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Verify OTP
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required String type,
  }) async {
    try {
      print('🔵 Verifying OTP for: $email');
      
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      
      print('🟢 OTP verification successful');
      print('🔵 User ID: ${response.user?.id}');
      print('🔵 Session exists: ${response.session != null}');
      
      return response;
    } catch (e) {
      print('❌ OTP verification failed: $e');
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      print('🔵 Resending verification email to: $email');
      
      await _supabase.auth.resend(
        type: OtpType.email,
        email: email,
      );
      
      print('✅ Verification email sent successfully');
    } catch (e) {
      print('❌ Failed to resend verification email: $e');
      throw AuthException('Failed to resend verification email: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // Create profile when user confirms email (fallback method if trigger fails)
  Future<void> createProfileIfNeeded({
    required String fullName,
    required String phoneNumber,
    required String address,
  }) async {
    final user = currentUser;
    if (user != null && user.emailConfirmedAt != null) {
      try {
        // Check if profile exists
        final existingProfile = await _supabase
            .from('user_profiles')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
        
        if (existingProfile == null) {
          // Use direct insert as fallback
          await _supabase.from('user_profiles').insert({
            'id': user.id,
            'email': user.email ?? '',
            'full_name': fullName,
            'phone_number': phoneNumber,
            'address': address,
            'created_at': DateTime.now().toIso8601String(),
          });
          print('Profile created after email confirmation (fallback)');
        }
      } catch (e) {
        print('Error creating profile after confirmation: $e');
      }
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}
