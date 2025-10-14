#!/bin/bash

echo "🌐 Joy Billiards 自定义域名配置脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否在正确的目录
if [ ! -f "package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

echo "📋 配置步骤："
echo ""
echo "1️⃣ 域名DNS配置 (在你的域名提供商):"
echo "   类型: CNAME"
echo "   名称: rank"
echo "   值: cname.vercel-dns.com"
echo "   TTL: 3600"
echo ""
echo "2️⃣ Vercel域名配置:"
echo "   • 登录 https://vercel.com/dashboard"
echo "   • 选择 joy-billiards 项目"
echo "   • Settings → Domains"
echo "   • 添加: rank.joybilliards.co.nz"
echo ""
echo "3️⃣ 环境变量更新:"
echo "   VITE_SITE_URL=https://rank.joybilliards.co.nz"
echo ""
echo "4️⃣ 推送更新到Vercel:"
echo "   正在推送当前配置..."

# 添加并提交更改
git add .
git commit -m "🌐 Add custom domain configuration

- Update vercel.json with enhanced security headers
- Add domain setup guide
- Prepare for rank.joybilliards.co.nz subdomain"

echo "✅ 配置已提交到Git"
echo ""
echo "🚀 推送到GitHub..."
echo "请手动运行: git push origin main"

echo ""
echo "🎉 配置完成！"
echo ""
echo "📋 下一步操作："
echo "1. 在域名提供商添加CNAME记录"
echo "2. 在Vercel添加自定义域名"
echo "3. 等待DNS传播 (通常5-30分钟)"
echo "4. 测试新域名访问"
echo ""
echo "📖 详细指南请查看: DOMAIN_SETUP_GUIDE.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
