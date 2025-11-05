-- ============================================================================
-- 彻底修复 point_history 引用问题
-- 在 Supabase SQL Editor 中运行此脚本
-- ============================================================================

-- 1. 删除旧表（point_history）上的所有策略
DROP POLICY IF EXISTS "Admins can insert point history" ON point_history;
DROP POLICY IF EXISTS "Admins can update point history" ON point_history;
DROP POLICY IF EXISTS "Admins can delete point history" ON point_history;
DROP POLICY IF EXISTS "Users can view their own point history" ON point_history;
DROP POLICY IF EXISTS "Public can view point history" ON point_history;

-- 2. 删除 ranking_point_history 上可能存在的旧策略
DROP POLICY IF EXISTS "Admins can insert point history" ON ranking_point_history;
DROP POLICY IF EXISTS "Admins can update point history" ON ranking_point_history;
DROP POLICY IF EXISTS "Admins can delete point history" ON ranking_point_history;
DROP POLICY IF EXISTS "Users can view their own point history" ON ranking_point_history;
DROP POLICY IF EXISTS "Public can view point history" ON ranking_point_history;

-- 3. 为 ranking_point_history 创建新的 RLS 策略
CREATE POLICY "Anyone can view ranking point history"
ON ranking_point_history
FOR SELECT
TO public
USING (true);

CREATE POLICY "Admins can insert ranking points"
ON ranking_point_history
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.auth_id = auth.uid() 
    AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can update ranking points"
ON ranking_point_history
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.auth_id = auth.uid() 
    AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can delete ranking points"
ON ranking_point_history
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.auth_id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- 4. 删除旧索引
DROP INDEX IF EXISTS idx_point_history_year;
DROP INDEX IF EXISTS idx_point_history_awarded_at;
DROP INDEX IF EXISTS idx_point_history_year_month_admin;
DROP INDEX IF EXISTS idx_point_history_user_year_points;
DROP INDEX IF EXISTS idx_point_history_user_year_month_points;
DROP INDEX IF EXISTS idx_point_history_awarded_at_year_month;

-- 5. 创建新索引
CREATE INDEX IF NOT EXISTS idx_ranking_point_history_user_id ON ranking_point_history(user_id);
CREATE INDEX IF NOT EXISTS idx_ranking_point_history_year ON ranking_point_history(year);
CREATE INDEX IF NOT EXISTS idx_ranking_point_history_user_year ON ranking_point_history(user_id, year);
CREATE INDEX IF NOT EXISTS idx_ranking_point_history_user_year_month ON ranking_point_history(user_id, year, month);
CREATE INDEX IF NOT EXISTS idx_ranking_point_history_awarded_at ON ranking_point_history(awarded_at DESC);

-- 6. 彻底删除 point_history 表（如果还存在）
DROP TABLE IF EXISTS point_history CASCADE;

-- 7. 查找并修复所有引用 point_history 的函数
-- 列出所有可能包含 point_history 的函数
SELECT 
  proname as function_name,
  prosrc as source
FROM pg_proc 
WHERE prosrc LIKE '%point_history%'
  AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- 完成验证
SELECT 
  'Migration completed!' as status,
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'point_history') as old_table_exists,
  EXISTS(SELECT 1 FROM information_schema.tables WHERE table_name = 'ranking_point_history') as new_table_exists;

