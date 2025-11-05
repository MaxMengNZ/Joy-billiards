# ✅ Joy Billiards - 快速启动检查清单

**目标：** 在 30 分钟内让系统运行起来！

---

## 📋 第一步：本地开发环境（10分钟）

### 1️⃣ 安装依赖（2分钟）
```bash
cd /Users/mengyang/Joy-billiards
npm install
```

**预期输出：**
```
added 245 packages in 45s
```

✅ **完成标志：** 看到 `node_modules/` 文件夹被创建

---

### 2️⃣ 创建环境变量文件（1分钟）

**方法 A：命令行创建**
```bash
cat > .env << 'EOF'
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFud3RxZ2RiZ3lxd3BzZHF2eGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NjM1NDQsImV4cCI6MjA3NTUzOTU0NH0.3sujc8r9taASBUTdXUbCR-oJQcjKgXrLAafYc7k0SU4
EOF
```

**方法 B：手动创建**
1. 复制 `env.example` 为 `.env`
2. 填入上面的密钥

✅ **完成标志：** `.env` 文件存在且包含正确的 URL 和密钥

---

### 3️⃣ 启动开发服务器（1分钟）
```bash
npm run dev
```

**预期输出：**
```
VITE v5.0.11  ready in 823 ms

➜  Local:   http://localhost:3000/
➜  Network: use --host to expose
➜  press h + enter to show help
```

✅ **完成标志：** 浏览器自动打开 http://localhost:3000

---

### 4️⃣ 验证连接（2分钟）

**检查项：**
- [ ] 页面能正常加载（看到 Joy Billiards 标志）
- [ ] 页脚显示 "🟢 Database Connected"（或隐藏但连接正常）
- [ ] 导航菜单正常工作
- [ ] 能访问 "Tournaments" 页面看到现有比赛

**如果看到错误：**
- 检查 `.env` 文件是否正确
- 打开浏览器控制台（F12）查看错误信息
- 重启开发服务器（Ctrl+C 然后 `npm run dev`）

---

## 📋 第二步：测试核心功能（10分钟）

### 5️⃣ 测试用户注册（3分钟）

1. 访问 http://localhost:3000/register
2. 填写表单：
   ```
   Full Name: Test User
   Email: test@example.com
   Password: password123
   Phone: 021 1234567
   ```
3. 点击 "Sign Up"

✅ **成功：** 跳转到登录页，显示 "注册成功"

---

### 6️⃣ 测试登录（2分钟）

1. 访问 http://localhost:3000/login
2. 使用刚才注册的邮箱和密码登录
3. 登录后会看到：
   - 右上角显示用户名 "👤 Test User"
   - 导航菜单多了 "Profile" 选项

✅ **成功：** 能看到个人资料页面

---

### 7️⃣ 测试查看数据（2分钟）

访问这些页面确认数据正常显示：
- [ ] **首页** - 看到统计数据（112个用户、2个比赛）
- [ ] **Tournaments** - 看到比赛列表
- [ ] **Rankings** - 看到排行榜
- [ ] **Membership** - 看到会员福利

✅ **成功：** 所有页面都能正常显示数据

---

### 8️⃣ 测试管理员功能（可选，3分钟）

**如何获得管理员权限：**

1. 打开 [Supabase SQL Editor](https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql/new)
2. 运行：
   ```sql
   UPDATE users 
   SET role = 'admin' 
   WHERE email = 'test@example.com';
   ```
3. 重新登录（Logout → Login）
4. 现在应该能看到：
   - 导航栏多了 "Admin" 和 "Players" 选项
   - 用户名旁边有 👑 图标

**测试管理功能：**
- [ ] 访问 `/admin` - 查看用户列表
- [ ] 访问 `/players` - 管理玩家
- [ ] 尝试添加积分、修改会员等级

✅ **成功：** 管理员功能正常工作

---

## 📋 第三步：准备部署（10分钟）

### 9️⃣ 清理项目（2分钟）

**检查嵌套文件夹：**
```bash
ls -la Joy-billiards/
```

如果看到 `Joy-billiards/Joy-billiards/`，需要清理：
```bash
# 先备份（以防万一）
# 然后删除重复的嵌套文件夹
```

---

### 🔟 修复安全问题（5分钟）

**打开 Supabase SQL Editor，运行以下修复：**

#### A. 启用 security_audit_log 的 RLS
```sql
-- 启用 RLS
ALTER TABLE security_audit_log ENABLE ROW LEVEL SECURITY;

-- 只允许管理员查看审计日志
CREATE POLICY "Admins can view audit log"
ON security_audit_log
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.auth_id = auth.uid() 
    AND users.role = 'admin'
  )
);
```

#### B. 启用密码泄露保护
1. 打开 https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/settings/auth
2. 找到 "Password Security"
3. 勾选 "Enable leaked password protection"

✅ **完成：** 安全警告减少

---

### 1️⃣1️⃣ 提交到 GitHub（3分钟）

```bash
# 添加所有文件（除了 .env，它已在 .gitignore 中）
git add .

# 提交
git commit -m "✨ Joy Billiards v2.0 - 会员系统+排名系统完成"

# 推送到远程
git push origin main
```

✅ **完成：** 代码已在 GitHub 上

---

## 📋 第四步：部署到 Vercel（可选）

### 1️⃣2️⃣ 连接 Vercel

1. 访问 https://vercel.com
2. 点击 "Import Project"
3. 选择你的 GitHub 仓库
4. 配置：
   ```
   Framework Preset: Vite
   Build Command: npm run build
   Output Directory: dist
   ```

### 1️⃣3️⃣ 添加环境变量

在 Vercel 项目设置中添加：
```
VITE_SUPABASE_URL = https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 1️⃣4️⃣ 部署

点击 "Deploy" - 等待 2-3 分钟

✅ **完成：** 网站已上线！

---

## 🎉 完成！

### 你现在拥有：
- ✅ 本地开发环境正常运行
- ✅ 所有功能经过测试
- ✅ 安全问题已修复
- ✅ 代码已提交到 GitHub
- ✅ （可选）网站已部署到 Vercel

---

## 🆘 常见问题

### Q: npm install 失败
**A:** 检查 Node.js 版本（需要 18+）
```bash
node -v
# 应该显示 v18.x 或更高
```

### Q: 数据库连接失败
**A:** 检查 `.env` 文件
```bash
cat .env
# 确认 URL 和密钥正确
```

### Q: 页面显示空白
**A:** 打开浏览器控制台（F12）查看错误
```
通常是：
1. .env 文件配置错误
2. npm install 未完成
3. 端口 3000 被占用
```

### Q: 无法登录
**A:** 检查邮箱是否已验证
```sql
-- 在 Supabase SQL Editor 中运行
SELECT email, email_verified FROM users WHERE email = 'your@email.com';

-- 手动验证邮箱
UPDATE users SET email_verified = true WHERE email = 'your@email.com';
```

---

## 📞 需要帮助？

### 文档资源
- **完整文档：** `README.md`
- **项目状态：** `PROJECT_STATUS_REPORT.md`
- **安全指南：** `SECURITY_FIX_GUIDE.md`

### Supabase Dashboard
- **SQL Editor：** https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql
- **Table Editor：** https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/editor
- **Auth Settings：** https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/auth/users

---

**准备好了吗？开始第一步吧！** 🚀

```bash
cd /Users/mengyang/Joy-billiards && npm install
```

