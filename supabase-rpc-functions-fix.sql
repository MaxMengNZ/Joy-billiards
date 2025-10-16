-- ============================================
-- 🔧 RPC FUNCTIONS FIX - Fix All Admin RPC Functions
-- ============================================
-- 
-- PROBLEM: All admin RPC functions were using wrong field mapping
-- They were using 'id = auth.uid()' but should use 'auth_id = auth.uid()'
-- This caused admin functions to fail and show "No users found"
-- 
-- SOLUTION: Fix all RPC functions to use correct field mapping
-- ============================================

-- Step 1: Fix get_all_users function
DROP FUNCTION IF EXISTS public.get_all_users();

CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    skill_level VARCHAR,
    role VARCHAR,
    wins INTEGER,
    losses INTEGER,
    is_active BOOLEAN,
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
    SELECT role INTO v_user_role
    FROM users
    WHERE auth_id = auth.uid();
    
    -- 如果不是管理员，拒绝访问
    IF v_user_role IS NULL OR v_user_role != 'admin' THEN
        RAISE EXCEPTION 'Access denied: Admin privileges required';
    END IF;

    -- 返回所有用户（绕过 RLS，因为是 SECURITY DEFINER）
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.name,
        u.phone,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.created_at,
        u.updated_at
    FROM users u
    ORDER BY u.created_at DESC;
END;
$$;

-- Step 2: Fix get_user_by_id function
DROP FUNCTION IF EXISTS public.get_user_by_id(UUID);

CREATE OR REPLACE FUNCTION public.get_user_by_id(user_id UUID)
RETURNS TABLE (
    id UUID,
    email VARCHAR,
    name VARCHAR,
    phone VARCHAR,
    skill_level VARCHAR,
    role VARCHAR,
    wins INTEGER,
    losses INTEGER,
    is_active BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 检查调用者是否有权限查看（自己或管理员）
    IF auth.uid() != user_id AND NOT EXISTS (
        SELECT 1 FROM users
        WHERE users.auth_id = auth.uid() 
        AND users.role = 'admin'
        AND users.is_active = true
    ) THEN
        RAISE EXCEPTION '❌ Access denied: You can only view your own profile';
    END IF;

    -- 返回用户数据
    RETURN QUERY
    SELECT 
        u.id,
        u.email,
        u.name,
        u.phone,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.created_at,
        u.updated_at
    FROM users u
    WHERE u.id = user_id;
END;
$$;

-- Step 3: Fix log_admin_action function
DROP FUNCTION IF EXISTS public.log_admin_action(VARCHAR, UUID, JSONB);

CREATE OR REPLACE FUNCTION public.log_admin_action(
    p_action VARCHAR,
    p_target_user_id UUID,
    p_details JSONB
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- 确保调用者是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE auth_id = auth.uid() 
        AND role = 'admin'
        AND is_active = true
    ) THEN
        RAISE EXCEPTION '❌ Access denied: Admin privileges required';
    END IF;

    -- 插入审计日志
    INSERT INTO admin_audit_log (
        admin_id,
        action,
        target_user_id,
        details
    ) VALUES (
        auth.uid(),
        p_action,
        p_target_user_id,
        p_details
    );
END;
$$;

-- Step 4: Fix update_user_role function
DROP FUNCTION IF EXISTS public.update_user_role(UUID, VARCHAR);

CREATE OR REPLACE FUNCTION public.update_user_role(
    p_user_id UUID,
    p_new_role VARCHAR
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_old_role VARCHAR;
BEGIN
    -- 检查是否是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE auth_id = auth.uid() 
        AND role = 'admin'
        AND is_active = true
    ) THEN
        RAISE EXCEPTION '❌ Access denied: Admin privileges required';
    END IF;

    -- 获取旧角色
    SELECT role INTO v_old_role FROM users WHERE id = p_user_id;

    -- 更新角色
    UPDATE users SET role = p_new_role WHERE id = p_user_id;

    -- 记录审计日志
    PERFORM log_admin_action(
        'UPDATE_ROLE',
        p_user_id,
        jsonb_build_object(
            'old_role', v_old_role,
            'new_role', p_new_role
        )
    );

    RETURN jsonb_build_object(
        'success', true,
        'message', 'User role updated successfully'
    );
END;
$$;

-- ============================================
-- 🔒 EXPECTED RESULT:
-- ============================================
-- 
-- After this fix:
-- - Admin dashboard will show all users
-- - Admin can view and manage all user data
-- - All admin RPC functions work correctly
-- - Security is maintained (only admins can access)
-- 
-- The key fix: auth_id = auth.uid() instead of id = auth.uid()
-- 
-- ============================================
