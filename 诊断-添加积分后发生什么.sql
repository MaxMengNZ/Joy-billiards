-- 诊断：添加 loyalty_points 后发生了什么

-- 1. 查看你的用户数据
SELECT 
  name,
  ranking_points as 段位积分,
  loyalty_points as 消费积分,
  ranking_level
FROM users
WHERE email = (SELECT email FROM users WHERE role = 'admin' LIMIT 1)
   OR id = (SELECT user_id FROM loyalty_point_history ORDER BY created_at DESC LIMIT 1);

-- 2. 查看最近的 loyalty_point_history 记录
SELECT 
  u.name,
  lph.points_change,
  lph.amount_spent_nzd,
  lph.multiplier,
  lph.reason,
  lph.created_at
FROM loyalty_point_history lph
JOIN users u ON u.id = lph.user_id
ORDER BY lph.created_at DESC
LIMIT 5;

-- 3. 查看最近的 ranking_point_history 记录
SELECT 
  u.name,
  rph.points_change,
  rph.reason,
  rph.year,
  rph.month,
  rph.awarded_at
FROM ranking_point_history rph
JOIN users u ON u.id = rph.user_id
ORDER BY rph.awarded_at DESC
LIMIT 5;

-- 4. 检查是否有函数错误地将 loyalty_points 插入到 ranking_point_history
-- 查看 admin_record_loyalty_points 函数定义
SELECT pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'admin_record_loyalty_points';


