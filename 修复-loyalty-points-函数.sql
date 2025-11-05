-- ============================================================================
-- 修复 admin_record_loyalty_points 函数
-- 问题：错误地将消费积分插入到 ranking_point_history（排名积分表）
-- 解决：应该插入到 loyalty_point_history（消费积分表）
-- ============================================================================

-- 1. 删除错误的记录（消费积分不应该在排名表里）
DELETE FROM ranking_point_history
WHERE reason LIKE '%×%';  -- 消费积分的标记是 ×1.4 这样的倍率

-- 2. 重新创建正确的函数
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
  SELECT membership_level INTO v_membership_level
  FROM users
  WHERE id = p_user_id;
  
  -- 根据会员等级计算倍率
  v_multiplier := CASE v_membership_level
    WHEN 'pro_max' THEN 1.6
    WHEN 'pro' THEN 1.4
    WHEN 'plus' THEN 1.2
    ELSE 1.0  -- lite
  END;
  
  -- 计算积分（1 NZD = 1 point × multiplier）
  v_points_earned := p_amount_nzd * v_multiplier;
  
  -- ✅ 插入到 LOYALTY_point_history（消费积分表）
  -- ❌ 不是 ranking_point_history！
  INSERT INTO loyalty_point_history (
    user_id,
    points_change,
    amount_spent_nzd,
    multiplier,
    membership_level,
    reason,
    recorded_by
  ) VALUES (
    p_user_id,
    v_points_earned,
    p_amount_nzd,
    v_multiplier,
    v_membership_level,
    p_description || ' (×' || v_multiplier || ')',
    p_recorded_by
  );
  
  -- 更新用户的 LOYALTY_points（不是 ranking_points！）
  UPDATE users
  SET 
    loyalty_points = loyalty_points + v_points_earned,
    updated_at = now()
  WHERE id = p_user_id
  RETURNING loyalty_points INTO v_new_balance;
  
  -- 记录审计日志
  INSERT INTO admin_audit_log (admin_id, action, target_user_id, details)
  VALUES (
    p_recorded_by,
    'record_loyalty_points',
    p_user_id,
    jsonb_build_object(
      'amount_nzd', p_amount_nzd,
      'points_earned', v_points_earned,
      'multiplier', v_multiplier,
      'reason', p_description
    )
  );
  
  -- 返回结果
  RETURN jsonb_build_object(
    'success', true,
    'points_earned', v_points_earned,
    'new_balance', v_new_balance,
    'multiplier', v_multiplier
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. 验证修复
SELECT 
  '=== 验证：ranking_point_history 应该为空 ===' as info;

SELECT 
  u.name,
  rph.points_change,
  rph.reason
FROM ranking_point_history rph
JOIN users u ON u.id = rph.user_id
ORDER BY rph.created_at DESC;

-- 应该没有记录！

SELECT 
  '=== loyalty_point_history 应该有消费记录 ===' as info;

SELECT 
  u.name,
  lph.points_change,
  lph.amount_spent_nzd,
  lph.multiplier,
  lph.reason
FROM loyalty_point_history lph
JOIN users u ON u.id = lph.user_id
ORDER BY lph.created_at DESC
LIMIT 5;

-- 4. 重新同步所有用户的积分（确保正确）
UPDATE users
SET ranking_points = (
  SELECT COALESCE(SUM(points_change), 0)
  FROM ranking_point_history
  WHERE user_id = users.id
);

-- 5. 最终验证
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM users
WHERE ranking_points > 0 OR loyalty_points > 0
ORDER BY ranking_points DESC, loyalty_points DESC
LIMIT 10;


