-- ============================================
-- 📊 USER STATS VIEW - Simplified User Statistics
-- ============================================
-- 
-- PURPOSE: Create a public view that returns only essential user statistics
-- Fields: id, name, created_at, wins, losses, break_and_run_count
-- 
-- This view is useful for:
-- - Public leaderboards
-- - Statistics pages
-- - Player rankings
-- - Performance tracking
-- 
-- Note: Only includes active users (is_active = true)
-- ============================================

-- Step 1: Drop existing view if it exists
DROP VIEW IF EXISTS public.user_stats_view;

-- Step 2: Create the user_stats_view
CREATE VIEW public.user_stats_view AS
SELECT 
    id,
    name,
    created_at,
    wins,
    losses,
    break_and_run_count
FROM users
WHERE is_active = true;

-- Step 3: Grant permissions
-- Allow authenticated users to read
GRANT SELECT ON public.user_stats_view TO authenticated;

-- Allow anonymous users to read (for public leaderboards)
GRANT SELECT ON public.user_stats_view TO anon;

-- ============================================
-- 📝 USAGE EXAMPLES:
-- ============================================

-- Example 1: Get all user stats
-- SELECT * FROM public.user_stats_view;

-- Example 2: Get top 10 players by wins
-- SELECT * FROM public.user_stats_view 
-- ORDER BY wins DESC 
-- LIMIT 10;

-- Example 3: Get players with Break and Run achievements
-- SELECT * FROM public.user_stats_view 
-- WHERE break_and_run_count > 0
-- ORDER BY break_and_run_count DESC;

-- Example 4: Calculate win rate
-- SELECT 
--     name,
--     wins,
--     losses,
--     CASE 
--         WHEN (wins + losses) > 0 
--         THEN ROUND((wins::numeric / (wins + losses)) * 100, 1)
--         ELSE 0 
--     END as win_rate_percentage
-- FROM public.user_stats_view
-- ORDER BY win_rate_percentage DESC;

-- ============================================
-- 🔒 SECURITY:
-- ============================================
-- 
-- ✅ No sensitive data exposed (email, phone, password)
-- ✅ Only active users visible (is_active = true)
-- ✅ Read-only access (SELECT only)
-- ✅ Safe for public use
-- 
-- ============================================
