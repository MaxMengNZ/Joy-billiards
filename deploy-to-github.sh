#!/bin/bash

# Joy Billiards - GitHub 部署脚本
# 运行此脚本前，请确保：
# 1. 已在 github.com 创建了空仓库 joy-billiards
# 2. 将下面的 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名

echo "🎱 Joy Billiards - GitHub 部署脚本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 检查是否已初始化 Git
if [ ! -d .git ]; then
    echo "📝 初始化 Git 仓库..."
    git init
    echo "✅ Git 仓库初始化完成"
else
    echo "✅ Git 仓库已存在"
fi

# 添加所有文件
echo ""
echo "📦 添加所有文件..."
git add .

# 提交
echo ""
echo "💾 提交代码..."
git commit -m "Initial commit - Joy Billiards Tournament System ready for deployment" || echo "⚠️  没有新的更改需要提交"

# 检查是否已有远程仓库
if git remote | grep -q origin; then
    echo "✅ 远程仓库已配置"
else
    echo ""
    echo "🔗 配置远程仓库..."
    echo "⚠️  请将下面的 YOUR_GITHUB_USERNAME 替换为你的 GitHub 用户名："
    echo ""
    echo "git remote add origin https://github.com/YOUR_GITHUB_USERNAME/joy-billiards.git"
    echo ""
    read -p "请输入你的 GitHub 用户名: " github_username
    
    if [ -z "$github_username" ]; then
        echo "❌ 未输入用户名，脚本退出"
        exit 1
    fi
    
    git remote add origin "https://github.com/$github_username/joy-billiards.git"
    echo "✅ 远程仓库配置完成"
fi

# 设置主分支名称为 main
echo ""
echo "🌿 设置主分支为 main..."
git branch -M main

# 推送到 GitHub
echo ""
echo "🚀 推送到 GitHub..."
echo "⚠️  如果这是第一次推送，GitHub 可能会要求你登录"
echo ""

git push -u origin main

# 检查推送结果
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 成功！代码已推送到 GitHub"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📋 下一步："
    echo "1. 访问 https://vercel.com"
    echo "2. 用 GitHub 登录"
    echo "3. Import 项目: joy-billiards"
    echo "4. 配置环境变量后部署"
    echo ""
    echo "详细步骤请查看: QUICK_DEPLOY.md"
    echo ""
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ 推送失败"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "可能的原因："
    echo "1. GitHub 仓库不存在"
    echo "2. 没有访问权限"
    echo "3. 网络问题"
    echo ""
    echo "解决方法："
    echo "1. 访问 https://github.com/new"
    echo "2. 创建新仓库，名称: joy-billiards"
    echo "3. 不要初始化 README、.gitignore 或 license"
    echo "4. 重新运行此脚本"
    echo ""
fi

