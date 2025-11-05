-- 检查 Sayed 的实际积分
SELECT 
  name,
  ranking_points,
  loyalty_points,
  ranking_level
FROM users
WHERE name LIKE '%Sayed%' OR name LIKE '%Basir%';
