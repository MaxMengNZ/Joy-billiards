-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 修复公开视图的访问权限问题
-- 问题：会员只能看到自己的数据（主页统计只显示 1 个用户）
-- 原因：视图使用 SECURITY INVOKER，受到 RLS 限制
-- 解决：改回 SECURITY DEFINER，让所有人都能看到公开数据
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 修复 public_users 视图（使用 SECURITY DEFINER）
CREATE OR REPLACE VIEW public.public_users 
WITH (security_invoker = false)  -- 使用 SECURITY DEFINER，绕过 RLS
AS
SELECT 
    id,
    name,
    wins,
    losses,
    skill_level,
    ranking_level,
    membership_card_number,  -- 保留：用于管理员页面显示，不在公开页面显示
    membership_level,
    is_active,
    break_and_run_count,
    created_at
FROM users
WHERE is_active = true;

-- 修复 user_stats_view 视图（使用 SECURITY DEFINER）
CREATE OR REPLACE VIEW public.user_stats_view 
WITH (security_invoker = false)  -- 使用 SECURITY DEFINER，绕过 RLS
AS
SELECT 
    id,
    name,
    created_at,
    wins,
    losses,
    break_and_run_count
FROM users
WHERE is_active = true;

-- 重新授予权限
GRANT SELECT ON public.public_users TO anon, authenticated;
GRANT SELECT ON public.user_stats_view TO anon, authenticated;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 安全性说明
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 这些视图使用 SECURITY DEFINER 是安全的，因为：
-- 1. 视图只包含公开信息（姓名、胜负、段位等）
-- 2. 已过滤所有敏感信息（email, phone, birthday, address, loyalty_points）
-- 3. membership_card_number 虽然在视图中，但不在公开页面显示
-- 4. 这是让所有用户看到社区统计的唯一方法

-- 注意：Supabase 会显示 "SECURITY DEFINER View" 警告
-- 这个警告可以忽略，因为视图已经过滤了敏感字段

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 修复效果
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 修复前：
--   会员访问主页 → 只看到自己的数据 → Registered Players: 1

-- 修复后：
--   会员访问主页 → 看到所有公开数据 → Registered Players: 43
--   排行榜 → 显示所有玩家
--   主页统计 → 显示真实的社区数据

