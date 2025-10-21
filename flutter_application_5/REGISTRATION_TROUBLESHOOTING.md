# Registration Issue - Troubleshooting Guide

## Problem
Users can register but no profile is created in the `user_profiles` table.

## Root Causes

### 1. **Email Confirmation Enabled**
- Supabase may require email confirmation before creating sessions
- Without a session, the user can't create their own profile due to RLS policies
- The trigger should handle this, but may not be working

### 2. **Missing/Broken Database Trigger**
- Trigger function doesn't exist or has errors
- Trigger not attached to `auth.users` table
- Function lacks proper permissions

### 3. **RLS Policies Too Restrictive**
- Service role can't insert profiles (needed for trigger)
- Authenticated users can't insert their own profiles
- Policies not set up correctly

### 4. **Table Structure Issues**
- `user_profiles` table doesn't exist
- Foreign key constraint issues
- Column mismatches

## Complete Fix

### Step 1: Run the SQL Script

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Navigate to **SQL Editor** → **New Query**
3. Copy the entire content of `REGISTRATION_FIX.sql`
4. Click **Run**
5. Check for success messages

### Step 2: Disable Email Confirmation (Optional - For Testing)

1. Go to **Authentication** → **Settings**
2. Scroll to **Email Auth** section
3. **Uncheck** "Enable email confirmations"
4. Click **Save**

This allows users to register and get immediate sessions without email confirmation.

### Step 3: Test Registration

1. Run your Flutter app
2. Try to register a new user with:
   - Email: test@example.com
   - Password: Test123!
   - Full name: Test User
   - Phone: 01712345678
   - Address: Test Address

3. Check the console logs for:
   ```
   🔵 Starting sign up process for: test@example.com
   🟢 User created in auth.users with ID: [uuid]
   🔵 Active session detected - creating profile directly
   ✅ Profile already exists (created by trigger)
   ```
   OR
   ```
   ⚠️ Profile not found - creating manually
   ✅ Profile created manually
   ```

### Step 4: Verify in Database

1. Go to **Table Editor** → **user_profiles**
2. Check if the new user appears
3. Verify all fields are populated

## Debugging Steps

### Check if Trigger Exists
```sql
SELECT trigger_name, event_object_table, action_timing
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';
```
Should return 1 row.

### Check if Function Exists
```sql
SELECT proname, prosecdef
FROM pg_proc
WHERE proname = 'handle_new_user';
```
Should return 1 row with `prosecdef = true` (SECURITY DEFINER).

### Check RLS Policies
```sql
SELECT policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'user_profiles';
```
Should return 5+ policies including one for `service_role`.

### Check Recent Users in Auth
```sql
SELECT id, email, created_at, email_confirmed_at, raw_user_meta_data
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;
```
This shows if users are being created in auth.

### Check Recent Profiles
```sql
SELECT id, email, full_name, created_at
FROM public.user_profiles
ORDER BY created_at DESC
LIMIT 5;
```
This shows if profiles are being created.

### Manual Profile Creation Test
```sql
-- Replace with actual user ID from auth.users
INSERT INTO public.user_profiles (id, email, full_name, phone_number, address)
VALUES (
  'user-id-from-auth-users',
  'test@example.com',
  'Test User',
  '01712345678',
  'Test Address'
);
```
If this fails, RLS policies are the issue.

## Common Errors and Solutions

### Error: "new row violates row-level security policy"
**Solution**: Service role policy is missing or incorrect.
```sql
CREATE POLICY "service_role_all_operations"
ON public.user_profiles
TO service_role
USING (true)
WITH CHECK (true);
```

### Error: "insert or update on table violates foreign key constraint"
**Solution**: User ID doesn't exist in auth.users. Check the user was created first.

### Error: "relation 'user_profiles' does not exist"
**Solution**: Create the table using the SQL script.

### Error: "function handle_new_user() does not exist"
**Solution**: Create the function using the SQL script.

### No Error But Profile Not Created
**Solutions**:
1. Check trigger is attached: `SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';`
2. Check function permissions: `GRANT EXECUTE ON FUNCTION handle_new_user() TO service_role;`
3. Enable logging in trigger function to see what's happening
4. Use manual fallback in Flutter code (already implemented)

## How the Fix Works

### Two-Tier Approach

**Tier 1: Database Trigger (Primary)**
- When user signs up, Supabase creates entry in `auth.users`
- Trigger `on_auth_user_created` fires automatically
- Function `handle_new_user()` runs with elevated privileges
- Profile inserted into `user_profiles` table
- Works regardless of email confirmation

**Tier 2: Manual Creation (Fallback)**
- Flutter app waits 1.5 seconds after signup
- Checks if profile exists
- If not, creates profile directly
- Only works if user has active session (no email confirmation)

### Why This Works

1. **Trigger** handles the case where email confirmation is enabled
2. **Manual creation** handles the case where trigger fails
3. **RLS policies** allow both methods to work
4. **Service role policy** gives trigger unlimited access
5. **Authenticated policy** allows users to create their own profiles

## Testing Checklist

- [ ] SQL script runs without errors
- [ ] Trigger exists in database
- [ ] Function exists with SECURITY DEFINER
- [ ] All 5 RLS policies created
- [ ] Service role policy present
- [ ] Email confirmation disabled (for testing)
- [ ] User can register through app
- [ ] Console shows profile creation logs
- [ ] User appears in auth.users table
- [ ] Profile appears in user_profiles table
- [ ] All profile fields populated correctly

## Still Not Working?

### Last Resort Options

**Option 1: Disable RLS Temporarily**
```sql
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;
```
⚠️ Only for testing! Re-enable after finding the issue.

**Option 2: Create Profile in App After Login**
After successful registration, immediately try to create profile:
```dart
if (response.session != null) {
  await supabase.from('user_profiles').insert({...});
}
```

**Option 3: Use Supabase Dashboard**
Manually create profile via Table Editor to test app functionality.

## Support

If you're still having issues after following this guide:
1. Check Supabase logs in Dashboard → Logs
2. Enable PostgreSQL logging for detailed errors
3. Verify your Supabase plan allows triggers
4. Check for any network/firewall issues

---

**Expected Outcome**: Users can register and their profile is automatically created in the `user_profiles` table within 2 seconds.
