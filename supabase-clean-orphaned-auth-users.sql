-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 🔧 清理孤儿 Auth 用户（Auth 中存在但 users 表中不存在的用户）
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 
-- 问题原因：
-- 之前删除数据时只删除了 users 表记录，但没有删除 Auth 记录
-- 导致出现"孤儿用户"（Auth中有，users表中没有）
-- 
-- 解决方案：
-- 查找所有在 auth.users 中存在但在 public.users 中不存在的用户
-- 并提供删除这些用户的 SQL
-- 
-- ⚠️ 注意：
-- 由于我们无法直接查询或修改 auth.users 表（需要特殊权限）
-- 这个问题需要通过 Supabase Dashboard 或 Management API 来解决
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 🔍 步骤1: 查询所有当前 users 表中的用户
-- 这将帮助我们识别哪些邮箱应该被保留
SELECT 
    email,
    name,
    auth_id,
    created_at
FROM public.users
ORDER BY created_at DESC;

-- 📋 根据上面的查询结果，以下邮箱应该在 Auth 中保留：
-- ✅ maxmengnz@qq.com (Max Meng - 管理员)
-- 其他所有邮箱都应该从 Auth 中删除

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 💡 解决方案（需要手动执行）：
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 方案1: 通过 Supabase Management API（推荐）
-- 需要使用 Supabase Service Role Key
-- 
-- 步骤：
-- 1. 获取 Service Role Key（在 Supabase Dashboard → Settings → API）
-- 2. 运行以下脚本删除孤儿用户

-- 方案2: 创建一个管理函数来处理（如果有足够权限）
-- 但通常 RLS 和 Security Definer 无法直接访问 auth.users

-- 方案3: 使用 Supabase CLI
-- supabase db reset --linked  (⚠️ 这会重置整个数据库，慎用！)

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 🎯 临时解决方案：改进注册逻辑
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 我已经在前端代码中添加了更好的错误处理
-- 当遇到孤儿用户时，会给用户清晰的提示
-- 建议用户使用其他邮箱或联系管理员

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- 📌 预防措施：创建一个触发器来同步删除
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- ⚠️ 注意：这个触发器只能在 users 表被删除时触发
-- 无法删除 auth.users（需要通过 API）
-- 但我们可以记录需要删除的用户

-- 创建一个表来记录需要从 Auth 中删除的用户
CREATE TABLE IF NOT EXISTS public.auth_cleanup_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_id UUID NOT NULL,
    email TEXT NOT NULL,
    deleted_from_users_at TIMESTAMPTZ DEFAULT NOW(),
    cleaned_from_auth BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建触发器函数：当 users 表删除记录时，记录到清理队列
CREATE OR REPLACE FUNCTION public.queue_auth_cleanup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp;
AS $$
BEGIN
    -- 将被删除的用户信息添加到清理队列
    INSERT INTO public.auth_cleanup_queue (auth_id, email, deleted_from_users_at)
    VALUES (OLD.auth_id, OLD.email, NOW());
    
    RETURN OLD;
END;
$$;

-- 创建触发器
DROP TRIGGER IF EXISTS trigger_queue_auth_cleanup ON public.users;
CREATE TRIGGER trigger_queue_auth_cleanup
    BEFORE DELETE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION public.queue_auth_cleanup();

-- 查询待清理的 Auth 用户
CREATE OR REPLACE FUNCTION public.get_auth_cleanup_queue()
RETURNS TABLE (
    id UUID,
    auth_id UUID,
    email TEXT,
    deleted_at TIMESTAMPTZ,
    days_since_deletion INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp;
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        acq.id,
        acq.auth_id,
        acq.email,
        acq.deleted_from_users_at,
        EXTRACT(DAY FROM NOW() - acq.deleted_from_users_at)::INTEGER as days_since_deletion
    FROM public.auth_cleanup_queue acq
    WHERE acq.cleaned_from_auth = FALSE
    ORDER BY acq.deleted_from_users_at DESC;
END;
$$;

-- 标记为已清理
CREATE OR REPLACE FUNCTION public.mark_auth_cleaned(p_queue_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp;
AS $$
BEGIN
    UPDATE public.auth_cleanup_queue
    SET cleaned_from_auth = TRUE
    WHERE id = p_queue_id;
    
    RETURN TRUE;
END;
$$;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ✅ 执行说明
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- 1. 在 Supabase SQL Editor 中运行本脚本
-- 2. 这将创建一个清理队列系统
-- 3. 未来删除 users 时，会自动记录到队列
-- 4. 管理员可以查看队列并手动清理 Auth 用户
-- 5. 清理完成后标记为已清理

-- 查询当前待清理的用户：
-- SELECT * FROM get_auth_cleanup_queue();

-- 标记为已清理（在手动删除 Auth 用户后）：
-- SELECT mark_auth_cleaned('queue_id_here');

