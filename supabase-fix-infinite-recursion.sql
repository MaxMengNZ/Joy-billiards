-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 修复无限递归错误
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 删除有问题的策略
DROP POLICY IF EXISTS users_select_policy ON users;
DROP POLICY IF EXISTS users_update_policy ON users;
DROP POLICY IF EXISTS users_insert_policy ON users;

-- 创建简单的策略（用户只能访问自己的数据）
CREATE POLICY users_select_own ON users
    FOR SELECT
    TO authenticated
    USING (auth_id = auth.uid());

CREATE POLICY users_update_own ON users
    FOR UPDATE
    TO authenticated
    USING (auth_id = auth.uid())
    WITH CHECK (auth_id = auth.uid());

CREATE POLICY users_insert_own ON users
    FOR INSERT
    TO authenticated
    WITH CHECK (auth_id = auth.uid());

-- 创建管理员策略（使用安全的 is_active_admin 函数）
CREATE POLICY admins_select_all ON users
    FOR SELECT
    TO authenticated
    USING (is_active_admin());

CREATE POLICY admins_update_all ON users
    FOR UPDATE
    TO authenticated
    USING (is_active_admin())
    WITH CHECK (is_active_admin());

CREATE POLICY admins_delete_all ON users
    FOR DELETE
    TO authenticated
    USING (is_active_admin());

-- 验证策略
SELECT 
    policyname,
    cmd,
    permissive
FROM pg_policies 
WHERE tablename = 'users'
ORDER BY policyname;

