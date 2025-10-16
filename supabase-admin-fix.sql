-- ============================================
-- 🔧 ADMIN ACCESS FIX - Restore Admin Dashboard Access
-- ============================================
-- 
-- PROBLEM: After security fix, admin users couldn't access admin dashboard
-- because RLS policies were too restrictive for admin users
-- 
-- SOLUTION: Add admin-specific RLS policies while maintaining security
-- ============================================

-- Step 1: Add admin policy for viewing all users
CREATE POLICY "Admins can view all users"
    ON users FOR SELECT
    USING (is_active_admin());

-- Step 2: Add admin policy for updating all users  
CREATE POLICY "Admins can update all users"
    ON users FOR UPDATE
    USING (is_active_admin())
    WITH CHECK (is_active_admin());

-- Step 3: Verify all policies exist
SELECT 
    policyname,
    cmd,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'users'
ORDER BY policyname;

-- ============================================
-- 🔒 FINAL SECURITY STATUS:
-- ============================================
-- 
-- ✅ anon role: NO ACCESS to users/public_users (secure)
-- ✅ authenticated role: SELECT/UPDATE on users (own data only)
-- ✅ admin users: SELECT/UPDATE on ALL users (admin dashboard access)
-- ✅ RLS policies: 
--    - Regular users: only own data (auth.uid() = id)
--    - Admin users: all data (is_active_admin())
-- 
-- This allows:
-- - Anonymous users: NO access (secure)
-- - Regular users: own profile + leaderboard
-- - Admin users: admin dashboard + all user management
-- 
-- ============================================
