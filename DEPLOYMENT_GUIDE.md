# 🚀 Joy Billiards 部署指南

## 📋 目录
1. [部署前检查清单](#部署前检查清单)
2. [推荐部署方案：Vercel（免费）](#推荐部署方案vercel免费)
3. [Supabase 生产环境配置](#supabase-生产环境配置)
4. [环境变量配置](#环境变量配置)
5. [域名和 SSL 配置](#域名和ssl配置)
6. [部署后测试](#部署后测试)
7. [故障排除](#故障排除)
8. [其他部署方案](#其他部署方案)

---

## ✅ 部署前检查清单

### 1. 代码完整性检查
- [x] ✅ 所有功能测试通过
- [x] ✅ 会员服务文档完整
- [x] ✅ 数据库优化完成（19个索引）
- [x] ✅ 错误处理系统完善
- [x] ✅ 加载优化（骨架屏）
- [x] ✅ 全站会员信息一致

### 2. Supabase 数据库检查
- [ ] ⚠️ 确认 Supabase 项目已启用 RLS（Row Level Security）
- [ ] ⚠️ 确认所有表的 RLS 策略正确
- [ ] ⚠️ 确认数据库索引已创建
- [ ] ⚠️ 确认 RPC 函数已部署
- [ ] ⚠️ 备份当前数据库（重要！）

### 3. 环境变量准备
- [ ] ⚠️ 获取 Supabase URL
- [ ] ⚠️ 获取 Supabase Anon Key
- [ ] ⚠️ 创建 `.env` 文件（本地测试）
- [ ] ⚠️ 准备生产环境变量

### 4. 安全检查
- [x] ✅ 没有硬编码的密钥或敏感信息
- [x] ✅ `.env` 文件已在 `.gitignore` 中
- [x] ✅ Supabase RLS 策略保护数据
- [x] ✅ Admin 权限验证完善

---

## 🚀 推荐部署方案：Vercel（免费）

### 为什么选择 Vercel？
- ✅ **完全免费** - 个人项目零成本
- ✅ **自动部署** - 推送代码自动部署
- ✅ **全球 CDN** - 超快访问速度
- ✅ **免费 SSL** - 自动 HTTPS
- ✅ **零配置** - 自动识别 Vite 项目
- ✅ **自定义域名** - 支持绑定自己的域名

---

## 📝 详细部署步骤

### 步骤 1：准备 Git 仓库

#### 1.1 初始化 Git（如果还没有）
```bash
cd /Users/mengyang/Desktop/JoyBilliards
git init
```

#### 1.2 创建 `.gitignore` 文件
```bash
# 确保 .gitignore 包含以下内容
echo "node_modules/
dist/
.env
.env.local
.DS_Store
*.log" > .gitignore
```

#### 1.3 提交代码
```bash
git add .
git commit -m "Initial commit - Joy Billiards ready for deployment"
```

#### 1.4 推送到 GitHub（推荐）

**选项 A：使用 GitHub Desktop（简单）**
1. 下载并安装 [GitHub Desktop](https://desktop.github.com/)
2. 打开 GitHub Desktop
3. File → Add Local Repository
4. 选择 `/Users/mengyang/Desktop/JoyBilliards`
5. 点击 "Publish repository"
6. 输入仓库名称：`joy-billiards`
7. 取消勾选 "Keep this code private"（或保持私有）
8. 点击 "Publish Repository"

**选项 B：使用命令行**
1. 在 GitHub.com 创建新仓库
2. 按照 GitHub 提供的命令推送：
```bash
git remote add origin https://github.com/你的用户名/joy-billiards.git
git branch -M main
git push -u origin main
```

---

### 步骤 2：部署到 Vercel

#### 2.1 创建 Vercel 账户
1. 访问 [Vercel.com](https://vercel.com)
2. 点击 "Sign Up"
3. **使用 GitHub 账号登录**（推荐，自动关联仓库）

#### 2.2 导入项目
1. 登录后，点击 "Add New..." → "Project"
2. 选择 "Import Git Repository"
3. 授权 Vercel 访问你的 GitHub
4. 找到并选择 `joy-billiards` 仓库
5. 点击 "Import"

#### 2.3 配置项目
- **Framework Preset**: 选择 "Vite"（自动检测）
- **Root Directory**: `.`（默认）
- **Build Command**: `npm run build`（自动填充）
- **Output Directory**: `dist`（自动填充）

#### 2.4 配置环境变量（重要！）
点击 "Environment Variables"，添加：

| Name | Value |
|------|-------|
| `VITE_SUPABASE_URL` | `https://qnwtqgdbgyqwpsdqvxfl.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | `你的 Supabase Anon Key`（见下方获取方法） |

#### 2.5 获取 Supabase Anon Key
1. 访问 [Supabase Dashboard](https://app.supabase.com)
2. 选择你的项目：`joybilliards`
3. 左侧菜单：Settings → API
4. 复制 "Project URL"（应该是 `https://qnwtqgdbgyqwpsdqvxfl.supabase.co`）
5. 复制 "anon public" key（以 `eyJ` 开头的长字符串）

#### 2.6 开始部署
1. 点击 "Deploy"
2. 等待 2-3 分钟（Vercel 会自动构建和部署）
3. 部署成功后，会显示：
   - ✅ **Your project is live!**
   - 🌐 预览链接：`https://joy-billiards.vercel.app`（自动生成）

---

### 步骤 3：验证部署

#### 3.1 访问网站
点击 Vercel 提供的链接，例如：
- `https://joy-billiards.vercel.app`
- 或 `https://joy-billiards-你的用户名.vercel.app`

#### 3.2 测试关键功能
1. ✅ 网站能正常加载
2. ✅ 注册功能正常（创建测试账号）
3. ✅ 登录功能正常
4. ✅ 个人主页显示正确
5. ✅ Admin Dashboard 访问正常（需要 admin 权限）
6. ✅ 会员页面显示正确
7. ✅ 比赛创建和管理正常

#### 3.3 常见问题检查
- 如果看到 "Missing Supabase environment variables"：
  → 检查环境变量是否正确配置
  → 重新部署：Vercel Dashboard → Deployments → 右上角 "..." → Redeploy

- 如果注册/登录失败：
  → 检查 Supabase URL 是否正确
  → 检查 Supabase Anon Key 是否正确
  → 检查 Supabase RLS 策略

---

## 🗄️ Supabase 生产环境配置

### 1. 确认 RLS（Row Level Security）已启用

访问 Supabase Dashboard：
1. Authentication → Policies
2. 确认所有表都有 RLS 策略：
   - ✅ `users` 表
   - ✅ `tournaments` 表
   - ✅ `matches` 表
   - ✅ `tournament_registrations` 表
   - ✅ `point_history` 表
   - ✅ `loyalty_points` 表

### 2. 检查数据库索引

在 Supabase SQL Editor 中运行：
```sql
-- 查看所有索引
SELECT 
    tablename, 
    indexname, 
    indexdef 
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```

应该看到 19 个索引（如果没有，运行项目中的 `database-simplification.sql`）

### 3. 确认 RPC 函数已部署

在 Supabase SQL Editor 中运行：
```sql
-- 查看所有 RPC 函数
SELECT 
    routinename, 
    routinetype 
FROM information_schema.routines 
WHERE routineschema = 'public'
ORDER BY routinename;
```

应该看到：
- ✅ `record_loyalty_points`
- ✅ `deduct_loyalty_points`

### 4. 创建第一个 Admin 用户

#### 4.1 注册一个测试账号
1. 在你的网站上注册：`https://your-site.vercel.app/register`
2. 填写信息：
   - 姓名：Test Admin
   - 邮箱：admin@joybilliards.co.nz
   - 密码：你的密码
   - 会员等级：Lite

#### 4.2 将其升级为 Admin
在 Supabase SQL Editor 中运行：
```sql
-- 将用户设为 Admin
UPDATE users
SET role = 'admin'
WHERE email = 'admin@joybilliards.co.nz';
```

#### 4.3 验证 Admin 权限
1. 退出登录
2. 使用 `admin@joybilliards.co.nz` 重新登录
3. 访问 Admin Dashboard
4. 应该能看到所有管理功能

---

## 🌐 域名和 SSL 配置（可选）

### 如果你有自己的域名（例如 joybilliards.co.nz）

#### 1. 在 Vercel 添加域名
1. Vercel Dashboard → 你的项目 → Settings → Domains
2. 点击 "Add"
3. 输入你的域名：`joybilliards.co.nz` 或 `www.joybilliards.co.nz`
4. 点击 "Add"

#### 2. 配置 DNS
Vercel 会提示你添加 DNS 记录，通常是：

**选项 A：CNAME 记录**（推荐）
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

**选项 B：A 记录**
```
Type: A
Name: @
Value: 76.76.21.21
```

#### 3. 等待 DNS 生效
- 通常需要 5-60 分钟
- Vercel 会自动配置 SSL 证书（免费）
- 完成后，你的网站就可以通过 `https://joybilliards.co.nz` 访问

---

## 🧪 部署后测试清单

### 基础功能测试
- [ ] 主页加载正常
- [ ] 注册功能正常
- [ ] 登录功能正常
- [ ] 退出登录正常
- [ ] 个人主页显示正确

### 会员功能测试
- [ ] 会员等级显示正确
- [ ] 会员福利列表正确
- [ ] Loyalty Points 显示正确
- [ ] 统计数据显示正确

### 比赛功能测试
- [ ] 查看比赛列表
- [ ] 查看比赛详情
- [ ] 报名参赛（如果开放）
- [ ] 比赛对阵图显示正确

### Admin 功能测试（Admin 账号）
- [ ] Admin Dashboard 访问正常
- [ ] 用户管理功能正常
- [ ] 玩家管理功能正常
- [ ] 创建比赛功能正常
- [ ] Loyalty Points 管理正常
- [ ] Ranking Points 管理正常

### 性能测试
- [ ] 首屏加载时间 < 3 秒
- [ ] 骨架屏显示正常
- [ ] 页面切换流畅
- [ ] 移动端显示正常

---

## 🔧 故障排除

### 问题 1：部署失败
**错误信息：** `Build failed`

**解决方法：**
1. 检查 `package.json` 中的依赖是否完整
2. 检查 `vite.config.js` 配置是否正确
3. 查看 Vercel 部署日志，找到具体错误

### 问题 2：网站显示空白
**可能原因：** 环境变量未配置

**解决方法：**
1. Vercel Dashboard → 你的项目 → Settings → Environment Variables
2. 确认 `VITE_SUPABASE_URL` 和 `VITE_SUPABASE_ANON_KEY` 已添加
3. 重新部署：Deployments → 最新部署 → "..." → Redeploy

### 问题 3：注册/登录失败
**可能原因：** Supabase 配置问题

**解决方法：**
1. 检查 Supabase URL 是否正确
2. 检查 Supabase Anon Key 是否正确
3. 检查 Supabase 项目是否暂停（免费版长期不用会暂停）
4. 在 Supabase Dashboard 中恢复项目

### 问题 4：Admin Dashboard 无权限
**可能原因：** 用户角色未设置为 admin

**解决方法：**
在 Supabase SQL Editor 中运行：
```sql
-- 查看用户角色
SELECT id, email, role FROM users;

-- 设置为 admin
UPDATE users SET role = 'admin' WHERE email = 'your-email@example.com';
```

### 问题 5：数据不显示或 N/A
**可能原因：** 数据库索引或 RLS 策略问题

**解决方法：**
1. 运行 `database-simplification.sql` 创建所有索引
2. 检查 RLS 策略是否正确
3. 查看浏览器控制台的错误信息

---

## 🔄 自动部署（推荐设置）

### 配置自动部署
当你推送代码到 GitHub 时，Vercel 会自动部署：

1. **主分支自动部署到生产环境**
   ```bash
   git add .
   git commit -m "Update feature"
   git push origin main
   ```
   → Vercel 自动部署到 `https://joybilliards.co.nz`

2. **开发分支自动部署到预览环境**
   ```bash
   git checkout -b feature/new-feature
   git add .
   git commit -m "Add new feature"
   git push origin feature/new-feature
   ```
   → Vercel 自动创建预览链接 `https://joy-billiards-git-feature-new-feature.vercel.app`

---

## 📊 监控和分析（可选）

### 1. Vercel Analytics（免费）
1. Vercel Dashboard → 你的项目 → Analytics
2. 点击 "Enable Analytics"
3. 可以看到：
   - 页面访问量
   - 用户地理分布
   - 性能指标

### 2. Supabase Dashboard
1. 访问 Supabase Dashboard
2. 可以看到：
   - 数据库大小
   - API 请求数
   - 活跃用户数

---

## 🎯 其他部署方案

### 方案 2：Netlify（免费）
类似 Vercel，步骤相同：
1. 访问 [Netlify.com](https://netlify.com)
2. 使用 GitHub 登录
3. 导入仓库
4. 配置环境变量
5. 部署

### 方案 3：Railway（免费额度）
支持更复杂的配置：
1. 访问 [Railway.app](https://railway.app)
2. 使用 GitHub 登录
3. 导入仓库
4. 自动部署

### 方案 4：自己的服务器（需要技术）
如果你有自己的服务器：
1. 构建项目：`npm run build`
2. 将 `dist` 文件夹上传到服务器
3. 配置 Nginx/Apache
4. 配置 SSL 证书

---

## 📞 需要帮助？

如果遇到任何问题：
1. 查看 Vercel 部署日志
2. 查看浏览器控制台错误
3. 查看 Supabase Dashboard 日志
4. 参考项目中的文档：
   - `QUICKSTART.md`
   - `TESTING_GUIDE.md`
   - `STATS_MANAGEMENT_GUIDE.md`

---

## 🎉 恭喜！

如果所有步骤都完成了，你的 Joy Billiards 网站现在已经上线了！

**你的网站地址：**
- Vercel 免费域名：`https://joy-billiards.vercel.app`
- 或你的自定义域名：`https://joybilliards.co.nz`

**下一步：**
1. 创建第一个 Admin 账号
2. 邀请测试用户注册
3. 创建第一个测试比赛
4. 收集用户反馈
5. 持续优化改进

🎱 **Good luck with Joy Billiards!**

---

*最后更新：2025-10-13*  
*Joy Billiards NZ - 新西兰专业台球俱乐部* 🎱

