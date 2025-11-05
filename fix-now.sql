-- 立即修复：清除所有错误的 ranking_points
-- 因为你说过要"重新输入正确的段位积分"

-- 1. 清零所有用户的 ranking_points（之前已经做过，但可能有遗漏）
UPDATE users 
SET 
  ranking_points = 0,
  ranking_level = 'beginner'
WHERE ranking_points > 0;

-- 2. 清空 ranking_point_history（确保没有错误记录）
DELETE FROM ranking_point_history;

-- 3. 验证清除结果
SELECT 
  COUNT(*) as total_users,
  SUM(CASE WHEN ranking_points = 0 THEN 1 ELSE 0 END) as users_with_zero_ranking,
  SUM(CASE WHEN ranking_points > 0 THEN 1 ELSE 0 END) as users_with_ranking
FROM users;

-- 4. 查看前10名（应该都是 ranking_points = 0）
SELECT 
  name,
  ranking_points,
  loyalty_points,
  ranking_level
FROM users
ORDER BY loyalty_points DESC
LIMIT 10;
