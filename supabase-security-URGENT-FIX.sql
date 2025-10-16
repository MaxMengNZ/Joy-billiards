-- ============================================
-- 🚨 URGENT SECURITY FIX - Public Users View
-- ============================================
-- 
-- PROBLEM: public_users view is accessible by anonymous users
-- This allows anyone to access user data via REST API
-- 
-- SOLUTION: Remove anon access and restrict to authenticated users only
-- ============================================

-- Step 1: Revoke ALL permissions from anon role on public_users
REVOKE ALL ON public_users FROM anon;

-- Step 2: Revoke write permissions from authenticated role
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON public_users FROM authenticated;

-- Step 3: Only allow SELECT for authenticated users (logged in users)
GRANT SELECT ON public_users TO authenticated;

-- Step 4: Verify the changes
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges 
WHERE table_name = 'public_users' 
ORDER BY grantee, privilege_type;

-- Step 5: Test that anon can no longer access the view
-- This should return 0 rows if successful
SELECT COUNT(*) as anon_access_count
FROM information_schema.table_privileges 
WHERE table_name = 'public_users' 
AND grantee = 'anon';

-- ============================================
-- 🔒 SECURITY NOTES:
-- ============================================
-- 
-- 1. public_users view now only accessible to authenticated users
-- 2. Anonymous users can no longer access user data via REST API
-- 3. Only logged-in users can view the leaderboard data
-- 4. This prevents the SQL injection attack shown in the screenshot
-- 
-- ============================================
