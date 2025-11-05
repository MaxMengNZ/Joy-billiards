-- ============================================================================
-- 修复 admin_record_loyalty_points 函数 V2
-- 先删除旧函数，再创建新的
-- ============================================================================

-- 1. 删除错误的记录（消费积分不应该在排名表）
DELETE FROM ranking_point_history
WHERE reason LIKE '%×%';

-- 2. 清零所有 ranking_points
UPDATE users SET ranking_points = 0, ranking_level = 'beginner';

-- 3. 删除旧函数
DROP FUNCTION IF EXISTS admin_record_loyalty_points(uuid,numeric,text,uuid);

-- 4. 重新创建正确的函数
CREATE OR REPLACE FUNCTION admin_record_loyalty_points(
  p_user_id UUID,
  p_amount_nzd NUMERIC,
  p_description TEXT,
  p_recorded_by UUID
) RETURNS jsonb AS $$
DECLARE
  v_membership_level TEXT;
  v_multiplier NUMERIC;
  v_points_earned NUMERIC;
  v_new_balance NUMERIC;
BEGIN
  -- 获取用户当前会员等级
  SELECT membership_level INTO v_membership_level FROM users WHERE id = p_user_id;
  
  -- 根据会员等级计算倍率
  v_multiplier := CASE v_membership_level
    WHEN 'pro_max' THEN 1.6
    WHEN 'pro' THEN 1.4
    WHEN 'plus' THEN 1.2
    ELSE 1.0
  END;
  
  -- 计算积分
  v_points_earned := p_amount_nzd * v_multiplier;
  
  -- ✅ 关键修复：插入到 loyalty_point_history（消费积分表）
  INSERT INTO loyalty_point_history (
    user_id,
    points_change,
    amount_spent_nzd,
    multiplier,
    membership_level,
    reason,
    recorded_by,
    created_at
  ) VALUES (
    p_user_id,
    v_points_earned,
    p_amount_nzd,
    v_multiplier,
    v_membership_level,
    p_description,
    p_recorded_by,
    now()
  );
  
  -- ✅ 更新 loyalty_points（不是 ranking_points！）
  UPDATE users
  SET loyalty_points = loyalty_points + v_points_earned
  WHERE id = p_user_id
  RETURNING loyalty_points INTO v_new_balance;
  
  -- 审计日志
  INSERT INTO admin_audit_log (admin_id, action, target_user_id, details)
  VALUES (
    p_recorded_by,
    'record_loyalty_points',
    p_user_id,
    jsonb_build_object(
      'amount_nzd', p_amount_nzd,
      'points_earned', v_points_earned,
      'multiplier', v_multiplier
    )
  );
  
  RETURN jsonb_build_object(
    'success', true,
    'points_earned', v_points_earned,
    'new_balance', v_new_balance,
    'multiplier', v_multiplier
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. 验证修复
SELECT '=== Ranking表应该为空 ===' as status;
SELECT COUNT(*) as count FROM ranking_point_history;

SELECT '=== Loyalty表应该有记录 ===' as status;
SELECT COUNT(*) as count FROM loyalty_point_history;

SELECT '=== 所有用户的 ranking_points 应该为 0 ===' as status;
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM users
WHERE ranking_points > 0 OR loyalty_points > 0
ORDER BY loyalty_points DESC
LIMIT 10;

