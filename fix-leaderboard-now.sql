-- ============================================================================
-- 一键修复排行榜显示错误
-- 立即在 Supabase SQL Editor 运行
-- ============================================================================

-- 1. 检查 Sayed 的数据
SELECT 
  '=== Sayed 的当前数据 ===' as info,
  name,
  ranking_points as 段位积分,
  loyalty_points as 消费积分,
  ranking_level as 段位等级
FROM users
WHERE name LIKE '%Sayed%';

-- 2. 检查他的段位积分历史
SELECT 
  '=== Sayed 的段位积分历史 ===' as info,
  points_change,
  reason,
  year,
  month,
  awarded_at
FROM ranking_point_history
WHERE user_id = (SELECT id FROM users WHERE name LIKE '%Sayed%' LIMIT 1);

-- 3. 如果他有段位积分历史但 ranking_points = 0，需要重新计算
UPDATE users
SET ranking_points = (
  SELECT COALESCE(SUM(points_change), 0)
  FROM ranking_point_history
  WHERE user_id = users.id
)
WHERE id = (SELECT id FROM users WHERE name LIKE '%Sayed%' LIMIT 1);

-- 4. 验证更新结果
SELECT 
  '=== 更新后的数据 ===' as info,
  name,
  ranking_points as 段位积分,
  loyalty_points as 消费积分
FROM users
WHERE name LIKE '%Sayed%';

-- 5. 如果他的 ranking_points 仍然是 0，但显示 22 分
-- 说明是从 loyalty_points 读取的（错误！）
-- 需要清空他的 loyalty_points 历史中的错误数据

-- 查看他的消费积分历史
SELECT 
  '=== Sayed 的消费积分历史 ===' as info,
  points_change,
  amount_spent_nzd,
  multiplier,
  reason,
  created_at
FROM loyalty_point_history
WHERE user_id = (SELECT id FROM users WHERE name LIKE '%Sayed%' LIMIT 1);


