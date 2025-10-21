# QUICK FIX - Registration Not Creating Profiles

## 🚨 5-Minute Fix

### Step 1: Run SQL Script (2 minutes)
1. Open https://supabase.com/dashboard
2. Select your project
3. Click **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy ALL content from `REGISTRATION_FIX.sql`
6. Paste and click **RUN**
7. Wait for "Success" message

### Step 2: Disable Email Confirmation (1 minute)
1. Click **Authentication** (left sidebar)
2. Click **Settings** tab
3. Scroll to **Email Auth** section
4. **UNCHECK** "Enable email confirmations"
5. Click **Save** at bottom

### Step 3: Test (2 minutes)
1. Run your Flutter app: `flutter run`
2. Go to Sign Up screen
3. Fill in:
   - Email: test123@example.com
   - Password: Test123!
   - Name: Test User
   - Phone: 01712345678
   - Address: Test Address
4. Click Sign Up
5. Watch console for:
   ```
   ✅ Profile created manually
   ```
   OR
   ```
   ✅ Profile already exists (created by trigger)
   ```

### Step 4: Verify (1 minute)
1. Back in Supabase Dashboard
2. Click **Table Editor**
3. Select **user_profiles** table
4. You should see the new user

## ✅ Success!
If you see the user in the table, registration is working!

## ❌ Still Not Working?

### Quick Diagnostic
Run this SQL query:
```sql
-- Check system status
SELECT 
  (SELECT COUNT(*) FROM auth.users) AS users,
  (SELECT COUNT(*) FROM public.user_profiles) AS profiles,
  (SELECT COUNT(*) FROM pg_policies WHERE tablename = 'user_profiles') AS policies,
  (SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created') AS triggers;
```

Expected result:
- policies: 5 or more
- triggers: 1

### If Policies = 0 or Triggers = 0
Re-run the SQL script from Step 1.

### If Still Failing
Check console for error messages and refer to `REGISTRATION_TROUBLESHOOTING.md`.

## 📝 What This Fixes

- ✅ Creates `user_profiles` table if missing
- ✅ Sets up Row Level Security policies
- ✅ Creates database trigger for automatic profile creation
- ✅ Grants proper permissions
- ✅ Enables manual fallback in Flutter code

## 🎯 Expected Result

After fix:
1. User registers → Account created in auth.users
2. Within 2 seconds → Profile created in user_profiles
3. User can immediately sign in and use the app
4. All user data properly stored

---
**Need More Help?** See `REGISTRATION_FIX_SUMMARY.md` for detailed explanation.
