# ⚡ Joy Billiards 快速部署指令

## 🎯 5 分钟部署到网络

按照以下步骤，你的网站将在 5 分钟内上线！

---

## ✅ 部署前检查清单

### 必须完成的准备工作：

- [ ] ✅ 已有 GitHub 账号（如果没有，去 [github.com](https://github.com) 注册）
- [ ] ✅ 已有 Vercel 账号（如果没有，去 [vercel.com](https://vercel.com) 用 GitHub 登录）
- [ ] ✅ 已有 Supabase Anon Key（从 Supabase Dashboard 复制）
- [ ] ✅ 项目代码在本地完整无错误

---

## 🚀 部署步骤（仅需 4 步）

### 步骤 1：推送代码到 GitHub

#### 选项 A：使用 GitHub Desktop（推荐，简单）

1. 下载并安装 [GitHub Desktop](https://desktop.github.com/)
2. 打开 GitHub Desktop
3. **File → Add Local Repository**
4. 选择文件夹：`/Users/mengyang/Desktop/JoyBilliards`
5. 点击 **"Publish repository"**
6. 仓库名称：`joy-billiards`
7. 描述：`Joy Billiards Tournament Management System`
8. 取消勾选 "Keep this code private"（或保持私有，随你）
9. 点击 **"Publish Repository"**

**完成！** 你的代码现在在 GitHub 上了。

---

#### 选项 B：使用命令行（如果你熟悉 Terminal）

打开 Terminal，运行以下命令：

```bash
# 进入项目目录
cd /Users/mengyang/Desktop/JoyBilliards

# 初始化 Git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit - Joy Billiards ready for deployment"

# 关联远程仓库（替换 YOUR_GITHUB_USERNAME）
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/joy-billiards.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

如果 GitHub 要求登录，输入你的用户名和密码（或 Personal Access Token）。

---

### 步骤 2：获取 Supabase Anon Key

1. 访问 [Supabase Dashboard](https://app.supabase.com)
2. 选择你的项目：**joybilliards**
3. 左侧菜单：**Settings → API**
4. 找到 **"Project URL"**：
   ```
   https://qnwtqgdbgyqwpsdqvxfl.supabase.co
   ```
5. 找到 **"anon public"** key（一长串以 `eyJ` 开头的字符串）
6. 点击 📋 复制按钮，保存到记事本

---

### 步骤 3：部署到 Vercel

1. 访问 [Vercel.com](https://vercel.com)
2. 点击 **"Sign Up"** 或 **"Login"**
3. 选择 **"Continue with GitHub"**（用 GitHub 登录）
4. 授权 Vercel 访问你的 GitHub
5. 点击 **"Add New..." → "Project"**
6. 找到 `joy-billiards` 仓库，点击 **"Import"**
7. **配置环境变量**（重要！）：
   - 点击 **"Environment Variables"**
   - 添加第一个变量：
     - Name: `VITE_SUPABASE_URL`
     - Value: `https://qnwtqgdbgyqwpsdqvxfl.supabase.co`
   - 添加第二个变量：
     - Name: `VITE_SUPABASE_ANON_KEY`
     - Value: 粘贴你刚才复制的 Anon Key（以 `eyJ` 开头）
8. 点击 **"Deploy"**

等待 2-3 分钟...

---

### 步骤 4：访问你的网站

部署完成后，Vercel 会显示：

```
✅ Your project is live!

🌐 https://joy-billiards.vercel.app
```

**点击链接，查看你的网站！**

---

## 🧪 测试你的网站

### 快速测试清单：

1. **[ ] 网站能打开**
   - 访问 `https://joy-billiards.vercel.app`
   - 应该看到主页

2. **[ ] 注册功能**
   - 点击右上角 "Register"
   - 填写信息并注册
   - 应该跳转到个人主页

3. **[ ] 登录功能**
   - 退出登录
   - 重新登录
   - 应该能正常登录

4. **[ ] 个人主页**
   - 查看会员卡
   - 查看统计数据
   - 应该显示正确

如果所有功能正常，**恭喜！你的网站已经上线了！** 🎉

---

## 🔧 如果遇到问题

### 问题 1：网站显示空白

**原因：** 环境变量没配置好

**解决：**
1. 进入 Vercel Dashboard
2. 选择你的项目
3. Settings → Environment Variables
4. 确认 `VITE_SUPABASE_URL` 和 `VITE_SUPABASE_ANON_KEY` 已添加
5. 如果没有，添加后重新部署：
   - Deployments → 最新部署 → "..." → Redeploy

---

### 问题 2：注册/登录失败

**原因：** Supabase 配置问题

**解决：**
1. 检查 Supabase URL 和 Anon Key 是否正确
2. 检查 Supabase 项目是否暂停（免费版长期不用会暂停）
3. 在 Supabase Dashboard 中恢复项目

---

### 问题 3：GitHub 推送失败

**错误：** `fatal: remote origin already exists`

**解决：**
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/joy-billiards.git
git push -u origin main
```

---

## 🎁 创建第一个 Admin 账号

部署成功后，你需要创建一个管理员账号来管理网站：

### 步骤：

1. **在网站上注册一个测试账号**
   - 访问 `https://joy-billiards.vercel.app/register`
   - 姓名：Admin User
   - 邮箱：admin@joybilliards.co.nz
   - 密码：你的密码
   - 会员等级：Lite

2. **在 Supabase 中升级为 Admin**
   - 访问 Supabase Dashboard
   - 左侧菜单：**SQL Editor**
   - 运行以下 SQL：
   ```sql
   UPDATE users
   SET role = 'admin'
   WHERE email = 'admin@joybilliards.co.nz';
   ```
   - 点击 **"Run"**

3. **重新登录**
   - 退出登录
   - 使用 `admin@joybilliards.co.nz` 重新登录
   - 访问 Admin Dashboard
   - 应该能看到所有管理功能

---

## 📋 下一步

网站上线后，你可以：

1. **邀请测试用户**
   - 分享链接给朋友或会员
   - 使用 `USER_TESTING_GUIDE.md` 指导他们测试
   - 收集反馈

2. **创建测试比赛**
   - 登录 Admin 账号
   - 创建一个测试比赛
   - 邀请测试用户报名

3. **配置自定义域名（可选）**
   - 如果你有 `joybilliards.co.nz` 域名
   - 参考 `DEPLOYMENT_GUIDE.md` 配置

4. **监控网站性能**
   - Vercel Dashboard → Analytics
   - Supabase Dashboard → Logs

---

## 🌐 你的网站信息

部署完成后，填写以下信息：

```
✅ 网站链接：https://joy-billiards.vercel.app
✅ Admin 邮箱：admin@joybilliards.co.nz
✅ Admin 密码：（你设置的密码）
✅ 部署时间：2025-10-XX XX:XX
✅ Vercel 项目：https://vercel.com/你的用户名/joy-billiards
✅ GitHub 仓库：https://github.com/你的用户名/joy-billiards
```

---

## 💡 有用的链接

- **Vercel Dashboard**: https://vercel.com/dashboard
- **Supabase Dashboard**: https://app.supabase.com
- **GitHub 仓库**: https://github.com/你的用户名/joy-billiards
- **完整部署指南**: 查看 `DEPLOYMENT_GUIDE.md`
- **测试指南**: 查看 `USER_TESTING_GUIDE.md`

---

## 🎉 恭喜！

你的 Joy Billiards 网站现在已经上线了！

**分享给你的会员，开始使用吧！** 🎱

需要帮助？查看 `DEPLOYMENT_GUIDE.md` 获取更详细的说明。

---

*Joy Billiards NZ - 新西兰专业台球俱乐部* 🎱

