# 🔐 紧急安全修复指南

## ⚠️ 发现的安全问题

### 🔴 严重漏洞：任何人都可以查看所有用户数据

**问题描述：**
- `users` 表没有启用行级安全 (RLS)
- 任何访问网站的人都可以打开浏览器开发者工具
- 直接查询 Supabase 数据库获取所有用户信息
- 包括：邮箱、手机号、会员信息、积分等敏感数据

**攻击方式示例：**
```javascript
// 任何人都可以在浏览器控制台执行：
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)
const { data } = await supabase.from('users').select('*')
console.log(data) // 😱 获取所有用户数据！
```

---

## 🛡️ 修复方案

### 第一步：在 Supabase 执行安全修复 SQL

1. **登录 Supabase Dashboard**
   - 访问：https://supabase.com/dashboard
   - 选择你的项目：`yknirqzqydsfbqmuxjll`

2. **打开 SQL Editor**
   - 左侧菜单 → SQL Editor
   - 点击 "New query"

3. **执行安全修复脚本**
   - 将 `supabase-security-fix.sql` 的内容复制粘贴
   - 点击 "Run" 执行
   - 等待执行完成（约 10-20 秒）

4. **验证结果**
   ```sql
   -- 检查 RLS 是否启用
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE tablename = 'users';
   
   -- 应该显示：rowsecurity = true
   ```

---

### 第二步：修改前端代码

#### 1. 修改 AdminDashboard.vue

**当前代码（不安全）：**
```javascript
// ❌ 直接查询 users 表
const { data, error } = await supabase
  .from('users')
  .select('*')
```

**修改为（安全）：**
```javascript
// ✅ 使用安全的 RPC 函数
const { data, error } = await supabase
  .rpc('get_all_users')
```

#### 2. 修改 PlayerStore.js

**当前代码（不安全）：**
```javascript
// ❌ 直接查询 users 表
const { data, error } = await supabase
  .from('users')
  .select('*')
  .order('wins', { ascending: false })
```

**修改为（安全）：**
```javascript
// ✅ 使用公开视图（只包含非敏感信息）
const { data, error } = await supabase
  .from('public_users')
  .select('*')
  .order('ranking_points', { ascending: false })
```

---

## 🔒 修复后的安全模型

### 数据访问权限

| 用户类型 | 可以访问的数据 | 限制 |
|---------|--------------|------|
| **未登录用户** | `public_users` 视图 | 只能看到公开信息（排行榜等） |
| **普通用户** | 自己的完整数据 | 不能看到其他用户的敏感信息 |
| **管理员** | 所有用户的完整数据 | 通过 `get_all_users()` RPC 函数 |

### RLS 策略说明

1. **用户只能查看自己的数据**
   ```sql
   CREATE POLICY "Users can view own data"
   ON users FOR SELECT
   USING (auth.uid() = id);
   ```

2. **管理员可以查看所有用户**
   ```sql
   CREATE POLICY "Admins can view all users"
   ON users FOR SELECT
   USING (
       EXISTS (
           SELECT 1 FROM users
           WHERE id = auth.uid() 
           AND role = 'admin'
           AND is_active = true
       )
   );
   ```

3. **用户不能修改敏感字段**
   - 不能修改自己的 `role`（角色）
   - 不能修改自己的 `loyalty_points`（积分）
   - 不能修改自己的 `ranking_points`（排名分）

---

## 🔍 安全测试

### 测试 1: 未登录用户无法访问敏感数据

1. 打开浏览器隐身模式
2. 访问网站（不登录）
3. 打开开发者工具 → Console
4. 执行：
   ```javascript
   const { createClient } = supabaseJs
   const supabase = createClient(
     'https://yknirqzqydsfbqmuxjll.supabase.co',
     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
   )
   const { data, error } = await supabase.from('users').select('*')
   console.log(data, error)
   ```
5. **预期结果：**
   - `data` 应该是空数组 `[]`
   - 或者返回错误（没有权限）

### 测试 2: 普通用户只能看到自己的数据

1. 以普通用户身份登录
2. 打开开发者工具 → Network
3. 查看网络请求
4. **预期结果：**
   - 只能看到自己的用户数据
   - 无法获取其他用户的邮箱、手机等

### 测试 3: 管理员可以访问所有数据

1. 以管理员身份登录
2. 访问 Admin Dashboard
3. **预期结果：**
   - 可以看到所有用户列表
   - 通过 `get_all_users()` RPC 函数获取

---

## 📊 审计日志

修复后，所有管理员操作都会被记录：

```sql
SELECT 
  al.*,
  u.full_name as admin_name,
  tu.full_name as target_name
FROM admin_audit_log al
LEFT JOIN users u ON al.admin_id = u.id
LEFT JOIN users tu ON al.target_user_id = tu.id
ORDER BY al.created_at DESC
LIMIT 100;
```

记录的操作包括：
- 修改用户角色
- 添加/扣除积分
- 停用/激活账号
- 修改会员等级

---

## ⚡ 立即执行的步骤

### 1. 数据库修复（5 分钟）

```bash
# 在 Supabase SQL Editor 执行
cat supabase-security-fix.sql
# 复制内容 → Supabase SQL Editor → Run
```

### 2. 前端代码修复（10 分钟）

需要修改的文件：
- ✅ `src/views/AdminDashboard.vue`
- ✅ `src/stores/playerStore.js`
- ✅ `src/views/LeaderboardPage.vue`

### 3. 测试验证（5 分钟）

- ✅ 测试未登录用户无法访问敏感数据
- ✅ 测试普通用户只能看到自己的数据
- ✅ 测试管理员功能正常

### 4. 部署上线（3 分钟）

```bash
git add .
git commit -m "🔒 紧急安全修复：启用 RLS 保护用户数据"
git push origin main
```

---

## 🚨 紧急情况处理

### 如果发现数据已被盗取

1. **立即通知所有用户**
   - 发送邮件通知
   - 建议用户修改密码

2. **检查审计日志**
   ```sql
   -- 查看最近的异常访问
   SELECT * FROM admin_audit_log 
   WHERE created_at > NOW() - INTERVAL '7 days'
   ORDER BY created_at DESC;
   ```

3. **考虑重置所有用户密码**
   - 通过 Supabase Auth 强制重置

4. **联系 Supabase 支持**
   - 检查是否有异常的 API 调用

---

## 📝 长期安全建议

### 1. 定期安全审计

- 每月检查 RLS 策略
- 审查审计日志
- 检查异常登录

### 2. 添加更多安全措施

```sql
-- 限制查询频率（防止暴力破解）
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 添加 IP 白名单（管理员操作）
CREATE TABLE admin_ip_whitelist (
  ip_address INET PRIMARY KEY,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 3. 使用环境变量保护密钥

```javascript
// ❌ 不要在代码中硬编码
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'

// ✅ 使用环境变量
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY
```

### 4. 启用 2FA（双因素认证）

- 为所有管理员账号启用
- 通过 Supabase Auth 配置

---

## ✅ 修复完成检查清单

在执行修复后，确认以下事项：

- [ ] ✅ `users` 表已启用 RLS
- [ ] ✅ RLS 策略已创建并测试
- [ ] ✅ `public_users` 视图已创建
- [ ] ✅ `get_all_users()` RPC 函数已创建
- [ ] ✅ 审计日志表已创建
- [ ] ✅ AdminDashboard 代码已修改
- [ ] ✅ PlayerStore 代码已修改
- [ ] ✅ 所有测试通过
- [ ] ✅ 代码已部署到生产环境
- [ ] ✅ 已通知用户（如有必要）

---

## 📞 需要帮助？

如果在修复过程中遇到问题：

1. **检查 Supabase 日志**
   - Dashboard → Logs → API

2. **检查浏览器控制台**
   - F12 → Console → 查看错误信息

3. **回滚方案**
   ```sql
   -- 如果出错，可以临时禁用 RLS
   ALTER TABLE users DISABLE ROW LEVEL SECURITY;
   
   -- 修复后再重新启用
   ALTER TABLE users ENABLE ROW LEVEL SECURITY;
   ```

---

## 🎯 总结

### 问题：
- ❌ 任何人都可以查看所有用户数据

### 修复：
- ✅ 启用 RLS，只有授权用户才能访问
- ✅ 管理员通过安全的 RPC 函数访问
- ✅ 添加审计日志，记录所有敏感操作

### 结果：
- 🔒 数据安全得到保障
- 📊 可追踪所有管理员操作
- 🛡️ 符合数据保护最佳实践

---

**⚠️ 请立即执行修复！这是一个严重的安全漏洞！**

