-- ============================================
-- 🔧 PUBLIC_USERS VIEW FIX - Add Missing Fields
-- ============================================
-- 
-- PROBLEM: public_users view was missing critical fields
-- - Missing: is_active (causing all players to show as "Inactive")
-- - Missing: membership_card_number (showing "N/A" for all players)
-- - Missing: membership_level (can't display membership info)
-- 
-- SOLUTION: Recreate view with all necessary fields
-- ============================================

-- Step 1: Drop existing view
DROP VIEW IF EXISTS public.public_users;

-- Step 2: Create view with all necessary fields
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
    created_at
FROM users
WHERE is_active = true;

-- Step 3: Grant SELECT permission to authenticated users
GRANT SELECT ON public.public_users TO authenticated;

-- ============================================
-- 🔒 EXPECTED RESULT:
-- ============================================
-- 
-- After this fix:
-- - Players Management page will show correct status (Active/Inactive)
-- - Card numbers will display correctly (JB-XXXX-XXXXXX)
-- - Membership levels will be visible
-- - All player information displayed correctly
-- 
-- The key fix: Added is_active, membership_card_number, membership_level
-- 
-- Note: The view only shows users where is_active = true
-- This is intentional for security and to hide deactivated users
-- 
-- ============================================
