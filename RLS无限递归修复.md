# 🔧 RLS 无限递归修复

**错误：** `infinite recursion detected in policy for relation "users"`  
**原因：** RLS 策略在检查权限时又查询 users 表，导致循环  
**状态：** ✅ 已修复

---

## 🐛 问题原因

### 错误的策略写法：
```sql
-- ❌ 会导致无限递归
CREATE POLICY "Admins can view all users"
ON users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users u  -- ❌ 在 users 表的策略中又查询 users 表！
    WHERE u.auth_id = auth.uid()
    AND u.role = 'admin'
  )
);
```

**递归流程：**
1. 用户查询 users 表
2. RLS 策略检查权限 → 需要查询 users 表找到用户角色
3. 查询 users 表 → 又触发 RLS 策略
4. 策略又查询 users 表 → 无限循环！💥

---

## ✅ 修复方案

### 正确的策略写法：

#### 方法 1：直接比较（最简单）
```sql
-- ✅ 用户查看自己的数据（不递归）
CREATE POLICY "Users view own data"
ON users FOR SELECT
USING (auth_id = auth.uid());  -- 直接比较，不查询其他表
```

#### 方法 2：使用 auth.users 表（避免递归）
```sql
-- ✅ 管理员权限检查（不递归到 users 表）
CREATE POLICY "Admins view all"
ON users FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM auth.users au  -- ✅ 查询 auth.users，不是 users
    WHERE au.id = auth.uid()
    AND au.raw_user_meta_data->>'role' = 'admin'
  )
);
```

#### 方法 3：使用函数（需要正确配置）
```sql
-- ✅ 使用 STABLE 函数（不会重复计算）
CREATE POLICY "Admins view all"
ON users FOR SELECT
USING (is_active_admin());  -- 函数内部使用缓存，避免递归
```

---

## 🔐 当前策略（已修复）

### SELECT（查看）策略
```sql
✅ "allow_own_select"
   - 用户可以查看自己
   - 或管理员可以查看所有人
   - 使用 auth.users 表，避免递归
```

### UPDATE（修改）策略
```sql
✅ "allow_own_update"
   - 用户可以修改自己的数据
```

### INSERT（创建）策略
```sql
✅ "allow_insert"
   - 注册时可以创建自己的记录
```

### DELETE（删除）策略
```sql
✅ "allow_admin_delete"
   - 只有管理员可以删除（通过 RPC）
```

---

## 🧪 测试验证

### Profile 页面测试：
1. 刷新 http://localhost:3000/profile
2. 应该能正常加载你的个人信息
3. 不应该再看到递归错误

### Admin 页面测试：
1. 访问 http://localhost:3000/admin
2. 应该能看到所有用户
3. 可以正常修改数据

---

## 📊 修复总结

### 删除的策略（有问题）：
- ❌ "Admins can view all users"（递归）
- ❌ "Users can view their own data"（重复）
- ❌ "Admins can update all users"（递归）
- ❌ "Users can update own profile"（重复）

### 新的策略（无递归）：
- ✅ "allow_own_select"
- ✅ "Admins view all"
- ✅ "allow_own_update"
- ✅ "Admins update all"

---

## ⚠️ 避免递归的原则

### ❌ 不要这样：
```sql
-- 在 users 表的策略中查询 users 表
ON users ... USING (
  EXISTS (SELECT 1 FROM users ...)  -- ❌ 递归！
)
```

### ✅ 应该这样：
```sql
-- 直接比较
USING (auth_id = auth.uid())  -- ✅ 简单直接

-- 或查询其他表
USING (
  EXISTS (SELECT 1 FROM auth.users ...)  -- ✅ 查询别的表
)

-- 或使用 STABLE 函数
USING (is_active_admin())  -- ✅ 函数避免重复查询
```

---

## ✅ 修复完成！

**刷新 Profile 页面，应该正常加载了！** 🎉

**http://localhost:3000/profile**

如果还有问题，告诉我具体的错误信息！


