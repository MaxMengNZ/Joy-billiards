-- ============================================
-- 🔧 BREAK AND RUN STATISTICS FIX
-- ============================================
-- 
-- PROBLEM: Break and Run statistics not displaying on HomePage
-- - public_users view was missing break_and_run_count field
-- - statsStore.js had hardcoded totalBreakAndRun = 0
-- - HomePage showed 0 even when users had Break and Run achievements
-- 
-- SOLUTION: Add break_and_run_count to view and update stats calculation
-- ============================================

-- Step 1: Drop and recreate public_users view with break_and_run_count
DROP VIEW IF EXISTS public.public_users;

CREATE VIEW public.public_users AS
SELECT 
    id,
    name,
    wins,
    losses,
    skill_level,
    ranking_level,
    membership_card_number,
    membership_level,
    is_active,
    break_and_run_count,
    created_at
FROM users
WHERE is_active = true;

-- Step 2: Grant SELECT permission to authenticated users
GRANT SELECT ON public.public_users TO authenticated;

-- Step 3: Test that Break and Run data is accessible
-- SELECT SUM(break_and_run_count) as total_break_and_run FROM public_users;

-- ============================================
-- 🔒 EXPECTED RESULT:
-- ============================================
-- 
-- After this fix:
-- - HomePage will show correct Break and Run total
-- - Stats will auto-update when players achieve Break and Run
-- - All Break and Run achievements will be counted
-- 
-- Example: If Kieran has 3 Break and Run achievements,
-- HomePage will now show "3" instead of "0"
-- 
-- The key fix: Added break_and_run_count to public_users view
-- Frontend (statsStore.js) now calculates: SUM(break_and_run_count)
-- 
-- ============================================
