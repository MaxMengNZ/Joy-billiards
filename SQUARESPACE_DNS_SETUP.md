# 🔧 Squarespace DNS配置指南

## 📋 概述
- **你的域名**: `joybilliards.co.nz` (通过Squarespace管理)
- **目标**: 设置 `rank.joybilliards.co.nz` 子域名指向Vercel
- **现有设置**: `www.joybilliards.co.nz` → Squarespace商城

## 🎯 配置目标
```
www.joybilliards.co.nz     → Squarespace商城 (保持不变)
rank.joybilliards.co.nz    → Vercel台球比赛系统 (新增)
```

## 📝 详细配置步骤

### 步骤 1: 登录Squarespace
1. 访问 [https://www.squarespace.com](https://www.squarespace.com)
2. 点击右上角 "Log In" 登录你的账户
3. 进入你的网站管理后台

### 步骤 2: 进入域名设置
1. 在左侧菜单中点击 **"Settings"** (设置)
2. 选择 **"Domains"** (域名)
3. 找到你的域名 `joybilliards.co.nz`
4. 点击域名旁边的 **"DNS Settings"** 或 **"Manage"**

### 步骤 3: 添加CNAME记录
1. 在DNS设置页面，点击 **"Add Record"** (添加记录)
2. 选择记录类型：**"CNAME"**
3. 填写以下信息：
   ```
   Host (主机): rank
   Points to (指向): cname.vercel-dns.com
   TTL: 3600 (或使用默认值)
   ```
4. 点击 **"Save"** (保存)

### 步骤 4: 验证配置
1. 确认新记录已添加成功
2. 记录应该显示为：
   ```
   类型: CNAME
   主机: rank
   指向: cname.vercel-dns.com
   ```

## ⚠️ 重要注意事项

### ✅ 可以做的：
- 添加新的 `rank` CNAME记录
- 保留现有的 `www` 记录
- 保留所有其他现有DNS记录

### ❌ 不要做的：
- 删除或修改现有的 `www` 记录
- 删除任何现有的A记录
- 修改MX记录（邮件相关）

## 🔍 故障排除

### 如果找不到DNS设置：
1. 确保你登录的是正确的Squarespace账户
2. 检查域名是否确实通过Squarespace管理
3. 尝试在 "Website" → "Settings" → "Domains" 中查找

### 如果添加记录失败：
1. 检查是否已有 `rank` 记录存在
2. 确保输入的值完全正确：`cname.vercel-dns.com`
3. 联系Squarespace客服支持

### 如果域名不生效：
1. 等待DNS传播（通常5-30分钟）
2. 使用在线工具测试：`ping rank.joybilliards.co.nz`
3. 检查Vercel中是否已添加域名

## 📞 Squarespace客服支持
如果遇到问题，可以通过以下方式联系：
- **在线聊天**: Squarespace网站右下角聊天图标
- **帮助中心**: [https://support.squarespace.com](https://support.squarespace.com)
- **电话支持**: 在帮助中心查找你所在地区的电话号码

## 🧪 测试DNS配置
配置完成后，可以使用以下方法测试：

### 方法1: 命令行测试
```bash
ping rank.joybilliards.co.nz
nslookup rank.joybilliards.co.nz
```

### 方法2: 在线工具
- [DNS Checker](https://dnschecker.org/)
- [What's My DNS](https://www.whatsmydns.net/)

### 方法3: 浏览器测试
直接在浏览器中访问 `https://rank.joybilliards.co.nz`

## 🎉 配置完成后的下一步
1. 在Vercel中添加自定义域名
2. 等待SSL证书自动配置
3. 测试所有功能正常工作
4. 更新网站链接和导航

---

## 📋 配置检查清单
- [ ] 登录Squarespace账户
- [ ] 找到DNS设置页面
- [ ] 添加CNAME记录：`rank` → `cname.vercel-dns.com`
- [ ] 保存记录
- [ ] 等待DNS传播
- [ ] 测试域名解析
- [ ] 在Vercel中添加域名

配置完成后，你的台球比赛系统就可以通过 `rank.joybilliards.co.nz` 访问了！
