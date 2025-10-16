-- ============================================
-- 🔐 完整安全修复 - 一次性解决所有问题
-- ============================================

-- ============================================
-- 第一步：禁用 RLS，清空所有策略
-- ============================================

-- 临时禁用 RLS
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 删除所有策略（使用不同的名称变体）
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'users') 
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON users', r.policyname);
    END LOOP;
END $$;

-- ============================================
-- 第二步：重新启用 RLS
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 第三步：创建最严格的策略
-- ============================================

-- 策略 1: SELECT - 用户只能查看自己的数据
CREATE POLICY "users_select_own"
    ON users
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

-- 策略 2: INSERT - 允许新用户注册
CREATE POLICY "users_insert_own"
    ON users
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- 策略 3: UPDATE - 用户只能更新自己的数据
CREATE POLICY "users_update_own"
    ON users
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- 策略 4: DELETE - 禁止所有删除
-- 不创建删除策略 = 默认禁止

-- ============================================
-- 第四步：确保 anon 角色没有访问权限
-- ============================================

-- 撤销 anon 角色对 users 表的所有权限
REVOKE ALL ON users FROM anon;
REVOKE ALL ON users FROM public;

-- 只授予 authenticated 角色基本权限
GRANT SELECT, INSERT, UPDATE ON users TO authenticated;

-- ============================================
-- 第五步：更新 get_all_users RPC（管理员专用）
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
DECLARE
    v_user_role VARCHAR;
BEGIN
    -- 检查当前用户角色
    SELECT role INTO v_user_role
    FROM users
    WHERE id = auth.uid();
    
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

-- ============================================
-- 第六步：确保 public_users 视图不包含敏感信息
-- ============================================

DROP VIEW IF EXISTS public_users;

CREATE VIEW public_users 
WITH (security_barrier = true)
AS
SELECT 
    id,
    name,
    wins,
    losses,
    skill_level,
    created_at
FROM users
WHERE is_active = true;

-- 允许所有人查看公开视图
GRANT SELECT ON public_users TO anon, authenticated;

-- ============================================
-- 第七步：验证配置
-- ============================================

DO $$
DECLARE
    v_rls_enabled BOOLEAN;
    v_policy_count INTEGER;
    v_anon_privs TEXT;
BEGIN
    -- 检查 RLS
    SELECT relrowsecurity INTO v_rls_enabled
    FROM pg_class
    WHERE relname = 'users';

    -- 统计策略
    SELECT COUNT(*) INTO v_policy_count
    FROM pg_policies
    WHERE tablename = 'users';

    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ 安全配置验证：';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE 'RLS 启用: %', v_rls_enabled;
    RAISE NOTICE '策略数量: %', v_policy_count;
    RAISE NOTICE '';
    
    IF v_rls_enabled AND v_policy_count = 3 THEN
        RAISE NOTICE '✅ 配置正确！';
        RAISE NOTICE '✅ 应该只有 3 个策略（SELECT, INSERT, UPDATE）';
        RAISE NOTICE '✅ anon 角色无法访问 users 表';
        RAISE NOTICE '✅ 只有 authenticated 用户能访问自己的数据';
    ELSE
        RAISE WARNING '⚠️  配置可能有问题';
        RAISE WARNING '预期 3 个策略，实际 %', v_policy_count;
    END IF;
    
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';
    RAISE NOTICE '现在请测试：未登录用户应该无法访问 users 表';
END $$;

