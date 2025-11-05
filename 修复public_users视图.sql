-- ============================================================================
-- 修复 public_users 视图 - 添加 ranking_points 字段
-- ============================================================================

-- 删除旧视图
DROP VIEW IF EXISTS public_users CASCADE;

-- 重新创建视图，包含所有需要的字段
CREATE OR REPLACE VIEW public_users AS
SELECT 
    id,
    name,
    email,
    phone,
    wins,
    losses,
    skill_level,
    ranking_level,
    ranking_points,        -- ✅ 段位积分（必须有！）
    loyalty_points,        -- ✅ 消费积分（仅供参考）
    membership_card_number,
    membership_level,
    membership_expires_at,
    break_and_run_count,
    is_active,
    last_match_date,
    created_at,
    updated_at
FROM users
WHERE is_active = true;

-- 授予权限
GRANT SELECT ON public_users TO anon, authenticated;

-- 验证视图包含所有字段
SELECT 
  column_name,
  data_type
FROM information_schema.columns 
WHERE table_name = 'public_users' 
  AND column_name IN ('ranking_points', 'loyalty_points')
ORDER BY column_name;

-- 测试查询
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM public_users
WHERE ranking_points > 0 OR loyalty_points > 0
LIMIT 5;

-- 完成！


