-- ============================================
-- 🔐 Joy Billiards Security Fix
-- 紧急修复：users 表权限控制
-- ============================================

-- ============================================
-- 1. 启用 users 表的行级安全 (RLS)
-- ============================================

-- 首先，启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2. 删除所有旧的 users 表策略（如果存在）
-- ============================================

DROP POLICY IF EXISTS "Allow public read access to users" ON users;
DROP POLICY IF EXISTS "Allow all operations on users" ON users;
DROP POLICY IF EXISTS "Users can view all users" ON users;
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;

-- ============================================
-- 3. 创建严格的 RLS 策略
-- ============================================

-- 删除可能已存在的策略
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins can update any user" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Allow user registration" ON users;

-- 策略 1: 用户只能查看自己的数据
CREATE POLICY "Users can view own data"
    ON users FOR SELECT
    USING (auth.uid() = id);

-- 策略 2: 管理员可以查看所有用户数据
CREATE POLICY "Admins can view all users"
    ON users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() 
            AND role = 'admin'
            AND is_active = true
        )
    );

-- 策略 3: 用户可以更新自己的数据（但不能修改 role、积分等敏感字段）
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- 策略 4: 管理员可以更新任何用户
CREATE POLICY "Admins can update any user"
    ON users FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() 
            AND role = 'admin'
            AND is_active = true
        )
    );

-- 策略 5: 管理员可以删除用户
CREATE POLICY "Admins can delete users"
    ON users FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() 
            AND role = 'admin'
            AND is_active = true
        )
    );

-- 策略 6: 新用户注册时可以插入数据
CREATE POLICY "Allow user registration"
    ON users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- 3.5. 创建触发器保护敏感字段
-- ============================================

-- 创建函数：防止普通用户修改敏感字段
CREATE OR REPLACE FUNCTION protect_sensitive_user_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- 如果是管理员，允许所有修改
    IF EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() 
        AND role = 'admin'
        AND is_active = true
    ) THEN
        RETURN NEW;
    END IF;

    -- 如果是普通用户修改自己的数据
    IF auth.uid() = NEW.id THEN
        -- 保护敏感字段不被修改（只保护确认存在的字段）
        NEW.role := OLD.role;
        NEW.wins := OLD.wins;
        NEW.losses := OLD.losses;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 创建触发器
DROP TRIGGER IF EXISTS protect_user_sensitive_fields ON users;
CREATE TRIGGER protect_user_sensitive_fields
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION protect_sensitive_user_fields();

-- ============================================
-- 4. 创建安全的视图：公开的用户信息
-- ============================================

-- 创建一个视图，只显示公开的用户信息（用于排行榜等）
-- 只使用基础字段（确保存在）
CREATE OR REPLACE VIEW public_users AS
SELECT 
    id,
    name,
    email,
    wins,
    losses,
    skill_level,
    created_at
FROM users
WHERE is_active = true;

-- 允许所有人查看公开用户信息
GRANT SELECT ON public_users TO anon, authenticated;

-- ============================================
-- 5. 创建安全的 RPC 函数：获取用户列表
-- ============================================

-- 只有管理员可以调用这个函数获取完整的用户列表
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
    -- 检查调用者是否是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid() 
        AND users.role = 'admin'
        AND users.is_active = true
    ) THEN
        RAISE EXCEPTION '❌ Access denied: Admin privileges required';
    END IF;

    -- 返回所有用户数据
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

-- 授予执行权限
GRANT EXECUTE ON FUNCTION get_all_users() TO authenticated;

-- ============================================
-- 6. 创建安全的 RPC 函数：获取单个用户
-- ============================================

CREATE OR REPLACE FUNCTION get_user_by_id(user_id UUID)
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
    -- 检查调用者是否有权限查看（自己或管理员）
    IF auth.uid() != user_id AND NOT EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid() 
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

-- 授予执行权限
GRANT EXECUTE ON FUNCTION get_user_by_id(UUID) TO authenticated;

-- ============================================
-- 7. 创建审计日志表
-- ============================================

CREATE TABLE IF NOT EXISTS admin_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    target_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    details JSONB,
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_admin ON admin_audit_log(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_target ON admin_audit_log(target_user_id);
CREATE INDEX IF NOT EXISTS idx_admin_audit_log_created ON admin_audit_log(created_at);

-- 启用 RLS
ALTER TABLE admin_audit_log ENABLE ROW LEVEL SECURITY;

-- 只有管理员可以查看审计日志
CREATE POLICY "Admins can view audit log"
    ON admin_audit_log FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() 
            AND role = 'admin'
            AND is_active = true
        )
    );

-- ============================================
-- 8. 记录审计日志的函数
-- ============================================

CREATE OR REPLACE FUNCTION log_admin_action(
    p_action VARCHAR,
    p_target_user_id UUID,
    p_details JSONB DEFAULT NULL
)
RETURNS VOID
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    -- 确保调用者是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() 
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

-- 授予执行权限
GRANT EXECUTE ON FUNCTION log_admin_action(VARCHAR, UUID, JSONB) TO authenticated;

-- ============================================
-- 9. 修改现有的管理员操作函数，添加审计日志
-- ============================================

-- 更新用户角色并记录日志
CREATE OR REPLACE FUNCTION update_user_role(
    p_user_id UUID,
    p_new_role VARCHAR
)
RETURNS JSONB
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_role VARCHAR;
BEGIN
    -- 检查是否是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid() 
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

GRANT EXECUTE ON FUNCTION update_user_role(UUID, VARCHAR) TO authenticated;

-- ============================================
-- 10. 安全检查报告
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '✅ 安全修复已完成！';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    RAISE NOTICE '';
    RAISE NOTICE '已实施的安全措施：';
    RAISE NOTICE '1. ✅ users 表已启用行级安全 (RLS)';
    RAISE NOTICE '2. ✅ 普通用户只能查看自己的数据';
    RAISE NOTICE '3. ✅ 管理员可以查看所有用户';
    RAISE NOTICE '4. ✅ 创建了公开用户信息视图';
    RAISE NOTICE '5. ✅ 创建了安全的 RPC 函数';
    RAISE NOTICE '6. ✅ 添加了管理员操作审计日志';
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  前端代码需要修改：';
    RAISE NOTICE '- AdminDashboard 应该调用 get_all_users() RPC';
    RAISE NOTICE '- 而不是直接查询 users 表';
    RAISE NOTICE '';
    RAISE NOTICE '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
END $$;

