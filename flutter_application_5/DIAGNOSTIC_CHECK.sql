-- Quick Diagnostic Script for Registration Issues
-- Run this to check the current state of your setup

-- 1. Check if user_profiles table exists
SELECT 
  'Table exists: ' || 
  CASE WHEN EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_profiles'
  ) THEN 'YES ✓' ELSE 'NO ✗' END AS table_status;

-- 2. Check table structure
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'user_profiles' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. Check if RLS is enabled
SELECT 
  tablename,
  rowsecurity AS rls_enabled
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename = 'user_profiles';

-- 4. Check RLS policies
SELECT 
  policyname,
  cmd AS operation,
  roles,
  CASE 
    WHEN qual IS NOT NULL THEN 'USING clause set'
    ELSE 'No USING clause'
  END AS using_status,
  CASE 
    WHEN with_check IS NOT NULL THEN 'WITH CHECK set'
    ELSE 'No WITH CHECK'
  END AS check_status
FROM pg_policies
WHERE tablename = 'user_profiles'
ORDER BY policyname;

-- 5. Check if trigger exists
SELECT 
  trigger_name,
  event_manipulation AS event,
  action_timing AS timing,
  event_object_table AS on_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

-- 6. Check if function exists
SELECT 
  proname AS function_name,
  prosecdef AS is_security_definer,
  provolatile AS volatility
FROM pg_proc
WHERE proname = 'handle_new_user';

-- 7. Check recent users in auth
SELECT 
  id,
  email,
  created_at,
  email_confirmed_at,
  (raw_user_meta_data->>'full_name') AS full_name_in_metadata
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- 8. Check recent profiles
SELECT 
  id,
  email,
  full_name,
  phone_number,
  created_at
FROM public.user_profiles
ORDER BY created_at DESC
LIMIT 5;

-- 9. Check if there are users without profiles
SELECT 
  u.id,
  u.email,
  u.created_at,
  CASE 
    WHEN p.id IS NULL THEN 'NO PROFILE ✗'
    ELSE 'HAS PROFILE ✓'
  END AS profile_status
FROM auth.users u
LEFT JOIN public.user_profiles p ON u.id = p.id
ORDER BY u.created_at DESC
LIMIT 10;

-- 10. Count statistics
SELECT 
  (SELECT COUNT(*) FROM auth.users) AS total_auth_users,
  (SELECT COUNT(*) FROM public.user_profiles) AS total_profiles,
  (SELECT COUNT(*) FROM auth.users WHERE email_confirmed_at IS NULL) AS unconfirmed_emails,
  (SELECT COUNT(*) 
   FROM auth.users u 
   LEFT JOIN public.user_profiles p ON u.id = p.id 
   WHERE p.id IS NULL) AS users_without_profiles;
