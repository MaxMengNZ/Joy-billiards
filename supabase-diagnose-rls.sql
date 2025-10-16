-- ============================================
-- 🔍 诊断 RLS 状态
-- ============================================

-- 1. 检查 RLS 是否启用
SELECT 
    schemaname,
    tablename,
    rowsecurity as "RLS 启用"
FROM pg_tables
WHERE tablename = 'users';

-- 2. 查看所有现有的策略
SELECT 
    schemaname,
    tablename,
    policyname as "策略名称",
    permissive as "允许性",
    roles as "角色",
    cmd as "命令类型",
    qual as "USING 条件",
    with_check as "WITH CHECK 条件"
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- 3. 显示策略数量
SELECT 
    COUNT(*) as "策略总数"
FROM pg_policies
WHERE tablename = 'users';

