# 🌐 Joy Billiards 域名配置指南

## 📋 当前域名状态
- **主域名**: `www.joybilliards.co.nz` (Squarespace商城)
- **目标**: 为台球比赛系统配置子域名

## 🎯 推荐子域名方案

### 1️⃣ 最佳方案: `tournaments.joybilliards.co.nz`
```
✅ 专业、清晰、易记
✅ 明确表示这是比赛系统  
✅ 与商城域名区分明确
✅ SEO友好
```

### 2️⃣ 备选方案:
- `app.joybilliards.co.nz` (应用系统)
- `games.joybilliards.co.nz` (游戏系统)
- `league.joybilliards.co.nz` (联赛系统)
- `admin.joybilliards.co.nz` (管理系统)

## 🔧 配置步骤

### 步骤 1: 域名DNS配置
在你的域名提供商 (通常是GoDaddy, Namecheap等) 添加以下DNS记录:

```
类型: CNAME
名称: tournaments (或你选择的子域名)
值: cname.vercel-dns.com
TTL: 3600 (或默认值)
```

### 步骤 2: Vercel域名配置
1. 登录 [Vercel Dashboard](https://vercel.com/dashboard)
2. 选择你的 `joy-billiards` 项目
3. 进入 **Settings** → **Domains**
4. 添加自定义域名: `tournaments.joybilliards.co.nz`
5. 等待DNS验证完成

### 步骤 3: 环境变量更新
在Vercel项目设置中更新环境变量:
```
VITE_SITE_URL=https://tournaments.joybilliards.co.nz
VITE_API_BASE_URL=https://tournaments.joybilliards.co.nz
```

### 步骤 4: 重定向配置
创建 `vercel.json` 配置文件 (已存在，需要更新):

```json
{
  "redirects": [
    {
      "source": "/",
      "destination": "/home",
      "permanent": false
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        }
      ]
    }
  ]
}
```

## 🌟 完整域名生态系统

```
www.joybilliards.co.nz     → Squarespace商城 (主站)
tournaments.joybilliards.co.nz → 台球比赛系统 (子站)
```

### 导航建议:
- 在主站商城添加 "比赛系统" 链接
- 在比赛系统添加 "返回商城" 链接
- 保持品牌一致性

## 📱 移动端优化
- 确保子域名在移动端正常访问
- 测试响应式设计
- 验证所有功能正常工作

## 🔒 SSL证书
- Vercel自动提供免费SSL证书
- 确保HTTPS重定向正常工作
- 验证证书有效性

## 🧪 测试清单
- [ ] DNS解析正常
- [ ] HTTPS访问正常  
- [ ] 所有页面加载正常
- [ ] 用户注册/登录功能正常
- [ ] 移动端响应式正常
- [ ] 与主站导航集成

## 💡 SEO优化建议
1. 在子域名添加适当的meta标签
2. 设置sitemap.xml
3. 配置robots.txt
4. 添加Google Analytics
5. 设置结构化数据

## 🚀 部署后步骤
1. 更新所有内部链接
2. 测试用户流程
3. 通知用户新域名
4. 更新社交媒体链接
5. 提交到搜索引擎

---

## 📞 需要帮助？
如果你在配置过程中遇到任何问题，请提供：
- 你的域名提供商
- 当前DNS设置截图
- 任何错误信息

我将协助你完成配置！
