-- ============================================================================
-- 紧急修复：创建 point_history 视图指向 ranking_point_history
-- 这样所有引用旧表名的代码和函数都能正常工作
-- ============================================================================

-- 1. 删除可能存在的旧表
DROP TABLE IF EXISTS point_history CASCADE;

-- 2. 创建视图（让 point_history 指向 ranking_point_history）
CREATE OR REPLACE VIEW point_history AS
SELECT * FROM ranking_point_history;

-- 3. 设置视图权限
GRANT SELECT ON point_history TO anon, authenticated;

-- 4. 验证
SELECT 
  'View created successfully!' as status,
  COUNT(*) as records_in_view
FROM point_history;

-- 5. 测试查询
SELECT * FROM point_history LIMIT 3;

-- 完成！现在所有引用 point_history 的代码都能工作了


