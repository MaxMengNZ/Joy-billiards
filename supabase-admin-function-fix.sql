-- ============================================
-- 🔧 ADMIN FUNCTION FIX - Fix is_active_admin Function
-- ============================================
-- 
-- PROBLEM: is_active_admin() function was using wrong field
-- It was using 'id = auth.uid()' but should use 'auth_id = auth.uid()'
-- This caused admin RLS policies to fail
-- 
-- SOLUTION: Fix the function to use correct field mapping
-- ============================================

-- Step 1: Fix is_active_admin function to use auth_id field
CREATE OR REPLACE FUNCTION public.is_active_admin()
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
AS $function$
    SELECT EXISTS (
        SELECT 1 
        FROM users
        WHERE auth_id = auth.uid()
        AND role = 'admin'
        AND is_active = true
    );
$function$;

-- Step 2: Verify the function definition
SELECT pg_get_functiondef(oid) as function_definition
FROM pg_proc 
WHERE proname = 'is_active_admin';

-- Step 3: Check admin user exists and has correct auth_id
SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    u.is_active,
    u.auth_id,
    au.id as auth_users_id
FROM users u
LEFT JOIN auth.users au ON u.auth_id = au.id
WHERE u.role = 'admin';

-- ============================================
-- 🔒 EXPECTED RESULT:
-- ============================================
-- 
-- After this fix:
-- - Admin users can access admin dashboard
-- - Admin users can view all user data
-- - Admin users can manage all users
-- - Regular users still restricted to own data
-- - Anonymous users still blocked
-- 
-- The key fix: auth_id = auth.uid() instead of id = auth.uid()
-- 
-- ============================================
