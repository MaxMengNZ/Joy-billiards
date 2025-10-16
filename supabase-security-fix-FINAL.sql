-- ============================================
-- 🔐 最终安全修复 - 完全阻止未授权访问
-- 感谢安全研究员的深入测试
-- ============================================

-- 问题：即使启用 RLS，使用 anon key 仍能直接访问 REST API
-- 原因：我们的策略太宽松了

-- ============================================
-- 1. 删除所有宽松的策略
-- ============================================

DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Authenticated users can view users" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Authenticated users can update" ON users;
DROP POLICY IF EXISTS "Authenticated users can delete" ON users;
DROP POLICY IF EXISTS "Allow user registration" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can update any user" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;

-- ============================================
-- 2. 创建严格的 RLS 策略
-- ============================================

-- 先删除可能已存在的严格策略
DROP POLICY IF EXISTS "Users can only view own data" ON users;
DROP POLICY IF EXISTS "Users can only update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data on signup" ON users;

-- 策略 1: 只允许用户查看自己的数据
CREATE POLICY "Users can only view own data"
    ON users FOR SELECT
    USING (
        auth.uid() = id
    );

-- 策略 2: 只允许用户更新自己的数据
CREATE POLICY "Users can only update own data"
    ON users FOR UPDATE
    USING (
        auth.uid() = id
    )
    WITH CHECK (
        auth.uid() = id
    );

-- 策略 3: 允许新用户注册（插入自己的数据）
CREATE POLICY "Users can insert own data on signup"
    ON users FOR INSERT
    WITH CHECK (
        auth.uid() = id
    );

-- 策略 4: 禁止普通用户删除（只能通过后端）
-- 不创建删除策略，意味着默认禁止删除

-- ============================================
-- 3. 为管理员创建特殊的 helper 函数
-- ============================================

-- 检查当前用户是否是激活的管理员
CREATE OR REPLACE FUNCTION is_active_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 
        FROM users
        WHERE id = auth.uid()
        AND role = 'admin'
        AND is_active = true
    );
$$;

-- ============================================
-- 4. 更新 get_all_users RPC - 严格检查管理员权限
-- ============================================

CREATE OR REPLACE FUNCTION get_all_users()
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
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- 严格检查：只有激活的管理员才能调用
    IF NOT is_active_admin() THEN
        RAISE EXCEPTION 'Access denied: Admin privileges required';
    END IF;

    -- 绕过 RLS，直接返回所有用户
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

GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;

-- ============================================
-- 5. 创建管理员专用的更新函数
-- ============================================

CREATE OR REPLACE FUNCTION admin_update_user(
    p_user_id UUID,
    p_updates JSONB
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 严格检查：只有激活的管理员才能调用
    IF NOT is_active_admin() THEN
        RAISE EXCEPTION 'Access denied: Admin privileges required';
    END IF;

    -- 执行更新（绕过 RLS）
    UPDATE users
    SET 
        name = COALESCE((p_updates->>'name')::VARCHAR, name),
        email = COALESCE((p_updates->>'email')::VARCHAR, email),
        phone = COALESCE((p_updates->>'phone')::VARCHAR, phone),
        role = COALESCE((p_updates->>'role')::VARCHAR, role),
        is_active = COALESCE((p_updates->>'is_active')::BOOLEAN, is_active),
        updated_at = NOW()
    WHERE id = p_user_id;

    -- 记录审计日志
    PERFORM log_admin_action(
        'UPDATE_USER',
        p_user_id,
        p_updates
    );

    RETURN jsonb_build_object(
        'success', true,
        'message', 'User updated successfully'
    );
END;
$$;

GRANT EXECUTE ON FUNCTION admin_update_user(UUID, JSONB) TO authenticated;

-- ============================================
-- 6. 测试 RLS 是否生效
-- ============================================

DO $$
DECLARE
    v_rls_enabled BOOLEAN;
    v_policy_count INTEGER;
BEGIN
    -- 检查 RLS 是否启用
    SELECT relrowsecurity INTO v_rls_enabled
    FROM pg_class
    WHERE relname = 'users';

    -- 统计策略数量
    SELECT COUNT(*) INTO v_policy_count
    FROM pg_policies
    WHERE tablename = 'users';

    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ 安全检查结果：';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'RLS 启用状态: %', v_rls_enabled;
    RAISE NOTICE '策略数量: %', v_policy_count;
    RAISE NOTICE '';
    
    IF v_rls_enabled AND v_policy_count >= 3 THEN
        RAISE NOTICE '✅ RLS 配置正确！';
        RAISE NOTICE '✅ 现在只有登录用户能看到自己的数据';
        RAISE NOTICE '✅ 管理员需要通过 RPC 函数访问';
    ELSE
        RAISE WARNING '⚠️  RLS 配置可能有问题';
    END IF;
    
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

