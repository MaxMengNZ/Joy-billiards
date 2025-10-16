-- ============================================
-- 🔧 RPC FUNCTIONS COMPLETE FIELDS FIX
-- ============================================
-- 
-- PROBLEM: get_all_users() and get_user_by_id() were missing critical fields
-- - Missing: membership_card_number, membership_level, membership_expires_at
-- - Missing: loyalty_points, membership_balance, ranking_level
-- - This caused Admin Dashboard to show "Lite" for all users and "N/A" for card numbers
-- 
-- SOLUTION: Add all necessary user fields to RPC function return types
-- ============================================

-- Step 1: Fix get_all_users() - Add all user fields
DROP FUNCTION IF EXISTS public.get_all_users();

CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS TABLE (
    id UUID,
    auth_id UUID,
    email VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    address TEXT,
    id_card VARCHAR,
    skill_level VARCHAR,
    role VARCHAR,
    wins INTEGER,
    losses INTEGER,
    is_active BOOLEAN,
    membership_card_number VARCHAR,
    membership_level VARCHAR,
    membership_expires_at TIMESTAMP WITH TIME ZONE,
    membership_points INTEGER,
    membership_balance NUMERIC,
    loyalty_points NUMERIC,
    ranking_level VARCHAR,
    last_match_date TIMESTAMP WITH TIME ZONE,
    last_recharge_date TIMESTAMP WITH TIME ZONE,
    break_and_run_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_role VARCHAR;
BEGIN
    -- 检查当前用户角色
    SELECT u.role INTO v_user_role
    FROM users u
    WHERE u.auth_id = auth.uid();
    
    -- 如果不是管理员，拒绝访问
    IF v_user_role IS NULL OR v_user_role != 'admin' THEN
        RAISE EXCEPTION 'Access denied: Admin privileges required';
    END IF;

    -- 返回所有用户的完整信息（绕过 RLS，因为是 SECURITY DEFINER）
    RETURN QUERY
    SELECT 
        u.id,
        u.auth_id,
        u.email,
        u.name,
        u.phone,
        u.address,
        u.id_card,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.membership_card_number,
        u.membership_level,
        u.membership_expires_at,
        u.membership_points,
        u.membership_balance,
        u.loyalty_points,
        u.ranking_level::VARCHAR,
        u.last_match_date,
        u.last_recharge_date,
        u.break_and_run_count,
        u.created_at,
        u.updated_at
    FROM users u
    ORDER BY u.created_at DESC;
END;
$$;

-- Step 2: Fix get_user_by_id() - Add all user fields
DROP FUNCTION IF EXISTS public.get_user_by_id(UUID);

CREATE OR REPLACE FUNCTION public.get_user_by_id(user_id UUID)
RETURNS TABLE (
    id UUID,
    auth_id UUID,
    email VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    address TEXT,
    id_card VARCHAR,
    skill_level VARCHAR,
    role VARCHAR,
    wins INTEGER,
    losses INTEGER,
    is_active BOOLEAN,
    membership_card_number VARCHAR,
    membership_level VARCHAR,
    membership_expires_at TIMESTAMP WITH TIME ZONE,
    membership_points INTEGER,
    membership_balance NUMERIC,
    loyalty_points NUMERIC,
    ranking_level VARCHAR,
    last_match_date TIMESTAMP WITH TIME ZONE,
    last_recharge_date TIMESTAMP WITH TIME ZONE,
    break_and_run_count INTEGER,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 检查调用者是否有权限查看（自己或管理员）
    IF auth.uid() != user_id AND NOT EXISTS (
        SELECT 1 FROM users u
        WHERE u.auth_id = auth.uid() 
        AND u.role = 'admin'
        AND u.is_active = true
    ) THEN
        RAISE EXCEPTION '❌ Access denied: You can only view your own profile';
    END IF;

    -- 返回用户的完整信息
    RETURN QUERY
    SELECT 
        u.id,
        u.auth_id,
        u.email,
        u.name,
        u.phone,
        u.address,
        u.id_card,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.membership_card_number,
        u.membership_level,
        u.membership_expires_at,
        u.membership_points,
        u.membership_balance,
        u.loyalty_points,
        u.ranking_level::VARCHAR,
        u.last_match_date,
        u.last_recharge_date,
        u.break_and_run_count,
        u.created_at,
        u.updated_at
    FROM users u
    WHERE u.id = user_id;
END;
$$;

-- ============================================
-- 🔒 EXPECTED RESULT:
-- ============================================
-- 
-- After this fix:
-- - Admin Dashboard will show correct membership levels (Pro, Pro Max, Plus, Lite)
-- - Admin Dashboard will show correct card numbers (JB-XXXX-XXXXXX)
-- - All user information will be displayed correctly
-- - Membership management will work properly
-- 
-- The key fix: Added all user table fields to RPC function return types
-- 
-- ============================================
