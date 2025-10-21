# Email Verification with OTP - Setup Guide

## Overview

The app now includes a complete email verification system with a 6-digit OTP (One-Time Password) flow. When users sign up, they'll receive a verification email and need to enter the OTP to complete registration.

## Features

✅ **6-Digit OTP Input** - Clean, user-friendly input fields
✅ **Auto-Focus** - Automatically moves to next field as user types
✅ **Auto-Verify** - Submits when all 6 digits are entered
✅ **Resend Code** - 60-second timer before allowing resend
✅ **Email Change** - Option to go back and change email
✅ **Profile Creation** - Creates user profile after verification
✅ **Visual Feedback** - Loading states, error messages, success notifications

## How It Works

### 1. User Flow

```
Sign Up Screen
    ↓
Enter details (name, email, password, etc.)
    ↓
Submit → Create auth.users account
    ↓
Email Verification Screen
    ↓
Enter 6-digit OTP from email
    ↓
Verify OTP
    ↓
Create user_profiles record
    ↓
Navigate to Home Screen
```

### 2. Technical Flow

**Sign Up (`sign_up_screen.dart`):**
```dart
// When user submits sign up form
final response = await signUp(...);
if (response != null) {
  // Navigate to verification screen
  Navigator.push(EmailVerificationScreen(...));
}
```

**Email Verification (`email_verification_screen.dart`):**
```dart
// User enters 6-digit OTP
await authService.verifyOtp(email, token);
// Create user profile
await authService.createProfileIfNeeded(...);
// Navigate to home
Navigator.pushAndRemoveUntil(HomeScreen());
```

## Supabase Configuration

### Enable Email Confirmation

1. Go to **Supabase Dashboard**
2. Navigate to **Authentication** → **Settings**
3. Scroll to **Email Auth**
4. ✅ **Enable email confirmations**
5. Configure email templates (optional)

### Email Templates (Optional)

Customize the verification email:

1. Go to **Authentication** → **Email Templates**
2. Select **Confirm signup**
3. Customize the template:

```html
<h2>Confirm Your Email</h2>
<p>Your verification code is: <strong>{{ .Token }}</strong></p>
<p>This code expires in 24 hours.</p>
```

## Database Setup

Make sure you have the user_profiles table and trigger:

```sql
-- Run this in Supabase SQL Editor if not already done
-- (From REGISTRATION_FIX.sql)

CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  phone_number TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can read own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- Service role policy (CRITICAL for trigger)
CREATE POLICY "Service role can insert any profile"
  ON user_profiles FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (
    id,
    full_name,
    phone_number,
    address,
    created_at
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.raw_user_meta_data->>'phone_number',
    NEW.raw_user_meta_data->>'address',
    NOW()
  );
  RETURN NEW;
END;
$$;

-- Trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  WHEN (NEW.email_confirmed_at IS NOT NULL)
  EXECUTE FUNCTION public.handle_new_user();
```

## Testing

### Test the Complete Flow

1. **Start the app:**
   ```bash
   flutter run
   ```

2. **Sign Up:**
   - Go to Sign Up screen
   - Fill in all fields
   - Click "Sign Up"

3. **Check Email:**
   - Open your email inbox
   - Find the verification email from Supabase
   - Note the 6-digit code

4. **Verify Email:**
   - App should automatically navigate to Email Verification Screen
   - Enter the 6-digit code
   - Code auto-submits when complete

5. **Verify Database:**
   ```sql
   -- Check if user was created
   SELECT * FROM auth.users WHERE email = 'your@email.com';
   
   -- Check if profile was created
   SELECT * FROM user_profiles WHERE id = '<user_id>';
   ```

### Test Scenarios

#### ✅ Successful Verification
- User receives email
- Enters correct OTP
- Profile created
- Navigates to home screen

#### ❌ Invalid OTP
- User enters wrong code
- Error message displayed
- Can retry or resend

#### 🔄 Resend Code
- Wait 60 seconds
- Click "Resend Code"
- New email sent
- Timer resets

#### ⏰ Expired OTP
- OTP expires after 24 hours
- Error message shown
- Can resend new code

#### 📧 Change Email
- Click "Change Email Address"
- Returns to sign up screen
- Can enter different email

## Troubleshooting

### Issue: Not Receiving Verification Email

**Possible Causes:**
1. Email in spam folder
2. Email confirmations disabled in Supabase
3. Invalid email address

**Solutions:**
```bash
# Check spam folder
# Verify Supabase email settings
# Use real email address (not temporary)
```

### Issue: OTP Verification Fails

**Possible Causes:**
1. Expired OTP (24 hours)
2. Wrong code entered
3. Already verified

**Solutions:**
```dart
// Click "Resend Code" to get new OTP
// Double-check the code from email
// Try signing in if already verified
```

### Issue: Profile Not Created

**Possible Causes:**
1. Database trigger not set up
2. RLS policies missing
3. Service role policy missing

**Solutions:**
```sql
-- Run REGISTRATION_FIX.sql
-- Verify trigger exists
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Verify policies
SELECT * FROM pg_policies 
WHERE tablename = 'user_profiles';
```

### Issue: "Session is null" Error

**Cause:** Email not verified yet

**Solution:** Complete OTP verification first

## Code Structure

### New Files Created

1. **`lib/screens/email_verification_screen.dart`**
   - OTP input UI
   - Verification logic
   - Resend functionality
   - Profile creation

### Modified Files

2. **`lib/services/auth_service.dart`**
   - Added `verifyOtp()` method
   - Added `resendVerificationEmail()` method

3. **`lib/providers/auth_provider.dart`**
   - Updated SignUpNotifier to return AuthResponse
   - Allows navigation based on response

4. **`lib/screens/sign_up_screen.dart`**
   - Navigates to EmailVerificationScreen after signup
   - Passes user data for profile creation

5. **`lib/constants/app_colors.dart`**
   - Added `borderColor` constant

## API Reference

### AuthService Methods

```dart
// Verify OTP
Future<AuthResponse> verifyOtp({
  required String email,
  required String token,
  required String type,
});

// Resend verification email
Future<void> resendVerificationEmail(String email);

// Create profile if needed (fallback)
Future<void> createProfileIfNeeded({
  required String fullName,
  required String phoneNumber,
  required String address,
});
```

### EmailVerificationScreen Parameters

```dart
EmailVerificationScreen({
  required String email,        // User's email address
  required String password,     // User's password
  required String fullName,     // Full name for profile
  required String phoneNumber,  // Phone for profile
  required String address,      // Address for profile
});
```

## Best Practices

### 1. Security
- ✅ OTP expires after 24 hours
- ✅ Rate limiting on resend (60 seconds)
- ✅ Secure token transmission
- ✅ Session validation

### 2. User Experience
- ✅ Clear instructions
- ✅ Visual feedback (loading, errors)
- ✅ Auto-focus between fields
- ✅ Auto-submit when complete
- ✅ Easy resend option

### 3. Error Handling
- ✅ Graceful error messages
- ✅ Fallback profile creation
- ✅ Network error handling
- ✅ Validation checks

## Next Steps

### Optional Enhancements

1. **Phone Verification:**
   - Add SMS OTP option
   - Two-factor authentication

2. **Social Auth:**
   - Google Sign-In
   - Apple Sign-In
   - Facebook Login

3. **Email Customization:**
   - Custom email templates
   - Branded emails
   - Multiple languages

4. **Advanced Features:**
   - Biometric authentication
   - Remember device
   - Session management

## Support

If you encounter issues:

1. Check logs in terminal for detailed error messages
2. Verify Supabase configuration
3. Run DIAGNOSTIC_CHECK.sql to verify database setup
4. Consult REGISTRATION_TROUBLESHOOTING.md

## Summary

✅ **Email verification system implemented**
✅ **6-digit OTP input with auto-verify**
✅ **Resend functionality with timer**
✅ **Profile creation after verification**
✅ **Complete error handling**
✅ **Clean, user-friendly UI**

The registration flow now includes proper email verification, ensuring users have valid email addresses and creating a secure authentication process.
