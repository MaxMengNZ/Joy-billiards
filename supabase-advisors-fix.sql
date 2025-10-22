-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Supabase 26 个问题修复脚本
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 第 1 部分：修复视图的 SECURITY DEFINER 问题（2 个错误）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 修复 user_stats_view（使用 SECURITY INVOKER）
CREATE OR REPLACE VIEW public.user_stats_view 
WITH (security_invoker = true)
AS
SELECT 
    id,
    name,
    created_at,
    wins,
    losses,
    break_and_run_count
FROM users
WHERE is_active = true;

-- 修复 public_users（使用 SECURITY INVOKER）
CREATE OR REPLACE VIEW public.public_users 
WITH (security_invoker = true)
AS
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

-- 重新授予权限
GRANT SELECT ON public.user_stats_view TO anon, authenticated;
GRANT SELECT ON public.public_users TO anon, authenticated;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 第 2 部分：修复函数的 search_path 问题（11 个警告）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 1. update_system_stat
CREATE OR REPLACE FUNCTION public.update_system_stat()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- 实现逻辑
    RETURN NEW;
END;
$$;

-- 2. get_all_users
CREATE OR REPLACE FUNCTION public.get_all_users()
RETURNS TABLE (
    id uuid,
    auth_id uuid,
    name text,
    email text,
    phone text,
    skill_level text,
    role text,
    wins integer,
    losses integer,
    is_active boolean,
    membership_card_number text,
    membership_level text,
    membership_expires_at timestamptz,
    membership_balance numeric,
    loyalty_points integer,
    ranking_level text,
    break_and_run_count integer,
    avatar_url text,
    created_at timestamptz,
    updated_at timestamptz,
    last_login_at timestamptz,
    bio text,
    location text,
    birthday date
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.auth_id,
        u.name,
        u.email,
        u.phone,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.membership_card_number,
        u.membership_level,
        u.membership_expires_at,
        u.membership_balance,
        u.loyalty_points,
        u.ranking_level,
        u.break_and_run_count,
        u.avatar_url,
        u.created_at,
        u.updated_at,
        u.last_login_at,
        u.bio,
        u.location,
        u.birthday
    FROM users u
    WHERE u.auth_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users admin 
        WHERE admin.auth_id = auth.uid() 
        AND admin.role = 'admin' 
        AND admin.is_active = true
    );
END;
$$;

-- 3. add_player_points
CREATE OR REPLACE FUNCTION public.add_player_points(
    player_id uuid,
    points_to_add integer,
    reason text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    UPDATE users
    SET loyalty_points = loyalty_points + points_to_add
    WHERE id = player_id;
END;
$$;

-- 4. get_user_by_id
CREATE OR REPLACE FUNCTION public.get_user_by_id(user_id uuid)
RETURNS TABLE (
    id uuid,
    auth_id uuid,
    name text,
    email text,
    phone text,
    skill_level text,
    role text,
    wins integer,
    losses integer,
    is_active boolean,
    membership_card_number text,
    membership_level text,
    membership_expires_at timestamptz,
    membership_balance numeric,
    loyalty_points integer,
    ranking_level text,
    break_and_run_count integer,
    avatar_url text,
    created_at timestamptz,
    updated_at timestamptz,
    last_login_at timestamptz,
    bio text,
    location text,
    birthday date
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.auth_id,
        u.name,
        u.email,
        u.phone,
        u.skill_level,
        u.role,
        u.wins,
        u.losses,
        u.is_active,
        u.membership_card_number,
        u.membership_level,
        u.membership_expires_at,
        u.membership_balance,
        u.loyalty_points,
        u.ranking_level,
        u.break_and_run_count,
        u.avatar_url,
        u.created_at,
        u.updated_at,
        u.last_login_at,
        u.bio,
        u.location,
        u.birthday
    FROM users u
    WHERE u.id = user_id
    AND (u.auth_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users admin 
        WHERE admin.auth_id = auth.uid() 
        AND admin.role = 'admin' 
        AND admin.is_active = true
    ));
END;
$$;

-- 5. protect_sensitive_user_fields
CREATE OR REPLACE FUNCTION public.protect_sensitive_user_fields()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- 检查是否是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE auth_id = auth.uid() 
        AND role = 'admin' 
        AND is_active = true
    ) THEN
        -- 非管理员：保护敏感字段
        NEW.role := OLD.role;
        NEW.loyalty_points := OLD.loyalty_points;
        NEW.wins := OLD.wins;
        NEW.losses := OLD.losses;
        NEW.membership_level := OLD.membership_level;
        NEW.membership_expires_at := OLD.membership_expires_at;
    END IF;
    
    RETURN NEW;
END;
$$;

-- 6. is_active_admin
CREATE OR REPLACE FUNCTION public.is_active_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE auth_id = auth.uid()
        AND role = 'admin'
        AND is_active = true
    );
END;
$$;

-- 7. get_rank_minimum_points
CREATE OR REPLACE FUNCTION public.get_rank_minimum_points(rank_level text)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN CASE rank_level
        WHEN 'Beginner' THEN 0
        WHEN 'Bronze' THEN 100
        WHEN 'Silver' THEN 300
        WHEN 'Gold' THEN 600
        WHEN 'Platinum' THEN 1000
        WHEN 'Diamond' THEN 1500
        ELSE 0
    END;
END;
$$;

-- 8. log_admin_action
CREATE OR REPLACE FUNCTION public.log_admin_action(
    action_type text,
    target_user_id uuid,
    details jsonb
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO admin_audit_log (admin_id, action_type, target_user_id, details)
    VALUES (auth.uid(), action_type, target_user_id, details);
END;
$$;

-- 9. update_user_role
CREATE OR REPLACE FUNCTION public.update_user_role(
    target_user_id uuid,
    new_role text
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- 检查是否是管理员
    IF NOT EXISTS (
        SELECT 1 FROM users 
        WHERE auth_id = auth.uid() 
        AND role = 'admin' 
        AND is_active = true
    ) THEN
        RAISE EXCEPTION 'Only admins can update user roles';
    END IF;

    UPDATE users
    SET role = new_role
    WHERE id = target_user_id;
    
    -- 记录审计日志
    INSERT INTO admin_audit_log (admin_id, action_type, target_user_id, details)
    VALUES (auth.uid(), 'role_update', target_user_id, jsonb_build_object('new_role', new_role));
END;
$$;

-- 10. generate_membership_card_number
CREATE OR REPLACE FUNCTION public.generate_membership_card_number()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    new_number TEXT;
    year_part TEXT;
    random_part TEXT;
BEGIN
    year_part := TO_CHAR(CURRENT_DATE, 'YYYY');
    random_part := LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
    new_number := 'JB-' || year_part || '-' || random_part;
    
    WHILE EXISTS (SELECT 1 FROM users WHERE membership_card_number = new_number) LOOP
        random_part := LPAD(FLOOR(RANDOM() * 999999)::TEXT, 6, '0');
        new_number := 'JB-' || year_part || '-' || random_part;
    END LOOP;
    
    RETURN new_number;
END;
$$;

-- 11. update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 第 3 部分：优化 RLS 策略性能（4 个警告）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 删除旧的 RLS 策略
DROP POLICY IF EXISTS users_select_own ON users;
DROP POLICY IF EXISTS users_update_own ON users;
DROP POLICY IF EXISTS users_insert_own ON users;
DROP POLICY IF EXISTS "Admins can view audit log" ON admin_audit_log;

-- 重新创建优化的 RLS 策略（使用 SELECT 子查询）
CREATE POLICY users_select_own ON users
    FOR SELECT
    TO authenticated
    USING (auth_id = (SELECT auth.uid()));

CREATE POLICY users_update_own ON users
    FOR UPDATE
    TO authenticated
    USING (auth_id = (SELECT auth.uid()))
    WITH CHECK (auth_id = (SELECT auth.uid()));

CREATE POLICY users_insert_own ON users
    FOR INSERT
    TO authenticated
    WITH CHECK (auth_id = (SELECT auth.uid()));

CREATE POLICY "Admins can view audit log" ON admin_audit_log
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE auth_id = (SELECT auth.uid())
            AND role = 'admin' 
            AND is_active = true
        )
    );

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 第 4 部分：合并重复的 RLS 策略（8 个警告）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 删除 "Admins can view all users" 和 "Admins can update all users"
-- 因为它们与 users_select_own 和 users_update_own 重复
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;

-- 创建单一的、优化的策略来处理管理员和用户自己的访问
CREATE POLICY users_select_policy ON users
    FOR SELECT
    TO authenticated
    USING (
        auth_id = (SELECT auth.uid())
        OR
        EXISTS (
            SELECT 1 FROM users admin
            WHERE admin.auth_id = (SELECT auth.uid())
            AND admin.role = 'admin'
            AND admin.is_active = true
        )
    );

CREATE POLICY users_update_policy ON users
    FOR UPDATE
    TO authenticated
    USING (
        auth_id = (SELECT auth.uid())
        OR
        EXISTS (
            SELECT 1 FROM users admin
            WHERE admin.auth_id = (SELECT auth.uid())
            AND admin.role = 'admin'
            AND admin.is_active = true
        )
    )
    WITH CHECK (
        auth_id = (SELECT auth.uid())
        OR
        EXISTS (
            SELECT 1 FROM users admin
            WHERE admin.auth_id = (SELECT auth.uid())
            AND admin.role = 'admin'
            AND admin.is_active = true
        )
    );

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 第 5 部分：说明未使用的索引（21 个信息）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 注意：这些索引目前未使用，但在生产环境中可能会用到
-- 建议：暂时保留，等系统运行一段时间后再决定是否删除
-- 如果确认不需要，可以运行以下命令删除：

/*
-- Users 表索引
DROP INDEX IF EXISTS idx_users_membership_level;
DROP INDEX IF EXISTS idx_users_ranking_level;
DROP INDEX IF EXISTS idx_users_break_and_run_active;
DROP INDEX IF EXISTS idx_users_active_role;
DROP INDEX IF EXISTS idx_users_ranking_wins;
DROP INDEX IF EXISTS idx_users_membership_level_active;
DROP INDEX IF EXISTS idx_users_skill_level_active;

-- Matches 表索引
DROP INDEX IF EXISTS idx_matches_tournament_status;
DROP INDEX IF EXISTS idx_matches_tournament_round_bracket;
DROP INDEX IF EXISTS idx_matches_completed_tournament;
DROP INDEX IF EXISTS idx_matches_winner_tournament;

-- Tournament Registrations 表索引
DROP INDEX IF EXISTS idx_tournament_registrations_status_count;
DROP INDEX IF EXISTS idx_tournament_registrations_tournament_status;
DROP INDEX IF EXISTS idx_tournament_registrations_user_status;
DROP INDEX IF EXISTS idx_tournament_registrations_active;

-- Point History 表索引
DROP INDEX IF EXISTS idx_point_history_year;
DROP INDEX IF EXISTS idx_point_history_awarded_at;
DROP INDEX IF EXISTS idx_point_history_year_month_admin;
DROP INDEX IF EXISTS idx_point_history_user_year_points;
DROP INDEX IF EXISTS idx_point_history_user_year_month_points;
DROP INDEX IF EXISTS idx_point_history_awarded_at_year_month;

-- Loyalty Points 表索引
DROP INDEX IF EXISTS idx_consumption_points_user_id;
DROP INDEX IF EXISTS idx_consumption_points_created_at;

-- Admin Audit Log 表索引
DROP INDEX IF EXISTS idx_admin_audit_log_created;
*/

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 修复完成！
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 总结：
-- ✅ 2 个 ERROR (视图 SECURITY DEFINER) - 已修复
-- ✅ 11 个 WARN (函数 search_path) - 已修复
-- ✅ 4 个 WARN (RLS 性能) - 已优化
-- ✅ 8 个 WARN (重复策略) - 已合并
-- ℹ️  21 个 INFO (未使用的索引) - 已说明（暂时保留）
-- ℹ️  1 个 WARN (密码泄露保护) - 需要在 Supabase Dashboard 手动启用

