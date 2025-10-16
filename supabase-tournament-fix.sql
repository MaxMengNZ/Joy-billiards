-- ============================================
-- 🔧 TOURNAMENT FIX - Fix Tournament Page Access
-- ============================================
-- 
-- PROBLEM: Tournament page showing "null is not an object (evaluating 'o.user.name')"
-- because tournament_registrations JOIN with users table was blocked by RLS
-- 
-- SOLUTION: Update public_users view to include ranking_level and fix queries
-- ============================================

-- Step 1: Update public_users view to include ranking_level field
DROP VIEW IF EXISTS public_users;

CREATE VIEW public_users AS
SELECT 
    id,
    name,
    wins,
    losses,
    skill_level,
    ranking_level,
    created_at
FROM users
WHERE is_active = true;

-- Step 2: Restore permissions for authenticated users
GRANT SELECT ON public_users TO authenticated;

-- Step 3: Verify the view has the correct fields
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'public_users' 
ORDER BY ordinal_position;

-- ============================================
-- 🔒 SECURITY STATUS:
-- ============================================
-- 
-- ✅ anon role: NO ACCESS to public_users (secure)
-- ✅ authenticated role: SELECT on public_users (tournament/leaderboard access)
-- ✅ public_users view: Contains safe fields (id, name, wins, losses, skill_level, ranking_level, created_at)
-- ✅ No sensitive data exposed (email, phone, etc.)
-- 
-- This allows:
-- - Tournament pages to display player information safely
-- - Leaderboard to show rankings
-- - No access to sensitive user data
-- 
-- ============================================
