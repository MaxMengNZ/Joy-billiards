-- ============================================
-- 🔧 LOGIN FIX - Restore Authenticated User Access
-- ============================================
-- 
-- PROBLEM: After security fix, authenticated users couldn't login
-- because they lost SELECT/UPDATE permissions on users table
-- 
-- SOLUTION: Restore necessary permissions while maintaining security
-- ============================================

-- Step 1: Restore SELECT permission for authenticated users
-- This allows logged-in users to read their own profile data
GRANT SELECT ON users TO authenticated;

-- Step 2: Restore UPDATE permission for authenticated users  
-- This allows logged-in users to update their own profile data
GRANT UPDATE ON users TO authenticated;

-- Step 3: Verify the permissions are restored
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges 
WHERE table_name = 'users' 
AND grantee = 'authenticated'
AND privilege_type IN ('SELECT', 'UPDATE')
ORDER BY privilege_type;

-- ============================================
-- 🔒 SECURITY STATUS AFTER FIX:
-- ============================================
-- 
-- ✅ anon role: NO ACCESS to users table (secure)
-- ✅ anon role: NO ACCESS to public_users view (secure)
-- ✅ authenticated role: SELECT/UPDATE on users table (for own data only via RLS)
-- ✅ authenticated role: SELECT on public_users view (for leaderboard)
-- ✅ RLS policies: Users can only access their own data
-- 
-- This maintains security while allowing normal login functionality
-- 
-- ============================================
