# 🚀 Vercel 部署指南

## ✅ 第一步：代码已推送到 GitHub

**仓库地址：** https://github.com/MaxMengNZ/Joy-billiards

**最新提交：** 🎉 完成移动端优化和视觉美化

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📋 第二步：在 Vercel 部署项目

### 1. 登录 Vercel

访问：https://vercel.com/login

使用 GitHub 账号登录（推荐）

### 2. 导入项目

点击 **"New Project"** 或 **"Add New..."** → **"Project"**

选择：**MaxMengNZ/Joy-billiards**

点击：**"Import"**

### 3. 配置项目

**Framework Preset:**
- 选择：`Vite`（自动检测）

**Root Directory:**
- 保持默认：`./`

**Build and Output Settings:**
- Build Command: `npm run build`（默认）
- Output Directory: `dist`（默认）
- Install Command: `npm install`（默认）

### 4. 配置环境变量 ⚠️ **重要！**

点击 **"Environment Variables"**

添加以下变量：

```
VITE_SUPABASE_URL=https://yknirqzqydsfbqmuxjll.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrbmlycXpxeWRzZmJxbXV4amxsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg2MTY3ODQsImV4cCI6MjA0NDE5Mjc4NH0.f3xkLn7RhDfAR5OHBzj_tCpCsB8XzDj5CHyJbxbzzx0
```

**注意：**
- 确保变量名前缀是 `VITE_`（不是 `VUE_APP_`）
- 环境选择：`Production`、`Preview`、`Development` 全选

### 5. 部署

点击：**"Deploy"**

等待 2-3 分钟...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🌐 第三步：配置自定义域名

### 1. 在 Vercel 项目设置中

部署成功后，进入项目 **Settings** → **Domains**

### 2. 添加域名

输入：`rank.joybilliards.co.nz`

点击：**"Add"**

### 3. Vercel 会提示你配置 DNS

你会看到：

```
⚠️ Invalid Configuration
Add a CNAME record with your DNS provider for:
rank.joybilliards.co.nz → cname.vercel-dns.com
```

### 4. 在 Squarespace 配置 DNS

登录 Squarespace → Settings → Domains → DNS

**已经配置好的记录：**
```
Type: CNAME
Host: rank
Target: cname.vercel-dns.com
TTL: 3600
```

### 5. 等待 DNS 生效

通常需要：5-10 分钟

最长可能：24-48 小时

### 6. 验证

在 Vercel 中点击 **"Refresh"** 或 **"Verify"**

成功后会显示：✅ **Valid Configuration**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ 第四步：测试部署

### 1. Vercel 默认域名

访问：`https://joy-billiards.vercel.app`

（或 Vercel 提供的其他域名）

### 2. 自定义域名（DNS 生效后）

访问：`https://rank.joybilliards.co.nz`

### 3. 测试功能

- ✅ 注册/登录
- ✅ 会员页面
- ✅ 排行榜
- ✅ 赛事页面
- ✅ 移动端底部导航
- ✅ Logo 显示
- ✅ 所有页面响应式

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 常见问题

### Q1: 部署后页面空白或报错？

**A:** 检查环境变量是否正确配置

1. 进入 Vercel 项目 → Settings → Environment Variables
2. 确认 `VITE_SUPABASE_URL` 和 `VITE_SUPABASE_ANON_KEY` 存在
3. 如果修改了环境变量，需要重新部署：
   - Deployments → 点击最新部署右侧的 "..." → Redeploy

### Q2: 自定义域名显示 "Invalid Configuration"？

**A:** DNS 记录可能还没生效

1. 检查 Squarespace DNS 记录是否正确：
   ```
   Type: CNAME
   Host: rank
   Target: cname.vercel-dns.com
   ```
2. 等待 5-10 分钟后刷新
3. 使用 DNS 检查工具：https://dnschecker.org/

### Q3: 部署成功，但功能不正常？

**A:** 检查 Supabase 配置

1. 确认 Supabase URL 和 Key 正确
2. 检查 Supabase 项目是否在线
3. 检查浏览器控制台是否有错误

### Q4: 如何重新部署？

**A:** 三种方式

**方式 1 - 推送代码（推荐）：**
```bash
git add .
git commit -m "更新内容"
git push origin main
```
Vercel 会自动触发部署

**方式 2 - Vercel 控制台：**
- Deployments → 最新部署 → ... → Redeploy

**方式 3 - Vercel CLI：**
```bash
npm install -g vercel
vercel --prod
```

### Q5: 如何查看部署日志？

**A:** Vercel 控制台

1. 进入项目
2. 点击 **Deployments**
3. 点击具体的部署
4. 查看 **Building**、**Function Logs** 等

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 部署后的自动化流程

### 每次推送代码到 GitHub：

1. Vercel 自动检测到 push
2. 自动拉取最新代码
3. 自动安装依赖 (`npm install`)
4. 自动构建 (`npm run build`)
5. 自动部署到生产环境
6. 发送部署成功/失败通知

### 好处：

✅ 无需手动部署
✅ 每次改动自动上线
✅ 支持回滚到任意版本
✅ 自动 HTTPS 证书
✅ 全球 CDN 加速

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 部署检查清单

部署前确认：
- ✅ 代码已推送到 GitHub
- ✅ 环境变量已配置
- ✅ Build 命令正确
- ✅ Output 目录正确

部署后确认：
- ✅ 默认域名可访问
- ✅ 自定义域名可访问（DNS 生效后）
- ✅ HTTPS 正常工作
- ✅ 注册/登录功能正常
- ✅ 数据库连接正常
- ✅ 移动端显示正常
- ✅ 所有页面加载正常

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚀 下一步

### 1. 监控和分析（可选）

**Vercel Analytics:**
- 进入项目 → Settings → Analytics
- 启用 Analytics（免费）
- 查看页面访问量、性能等

**Supabase Monitoring:**
- 进入 Supabase 项目
- 查看 Database → Usage
- 查看 Auth → Users

### 2. 性能优化（可选）

**图片优化:**
- 使用 WebP 格式
- 添加懒加载

**代码分割:**
- 已使用 Vue Router 懒加载
- 考虑组件懒加载

**缓存策略:**
- Vercel 自动处理
- 可自定义 `vercel.json`

### 3. 备份和版本控制

**定期备份:**
- GitHub 自动保存所有版本
- Supabase 自动备份数据库

**版本管理:**
- 使用 Git Tag 标记重要版本
- 可随时回滚到任意版本

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📞 支持和资源

**Vercel 文档:**
- https://vercel.com/docs

**Supabase 文档:**
- https://supabase.com/docs

**Vue.js 文档:**
- https://vuejs.org/guide/

**问题反馈:**
- GitHub Issues: https://github.com/MaxMengNZ/Joy-billiards/issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎉 恭喜！

你的台球赛事管理系统已经准备好部署到全球了！

**总结:**
1. ✅ 代码已推送到 GitHub
2. ⏳ 接下来在 Vercel 导入项目
3. ⏳ 配置环境变量
4. ⏳ 部署并测试
5. ⏳ 配置自定义域名（已在 Squarespace 设置好 DNS）

**预计时间:**
- Vercel 配置：5 分钟
- 首次部署：2-3 分钟
- DNS 生效：5-10 分钟

**总计：约 15 分钟即可完成！**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

祝你部署顺利！🚀
