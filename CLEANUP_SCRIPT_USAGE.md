# 🔧 Auth 用户清理脚本使用指南

## 📋 准备工作

### 1️⃣ 安装 Python 依赖

```bash
pip install requests
```

### 2️⃣ 获取 Service Role Key

这是最关键的一步！

1. **打开 Supabase Dashboard**
   - 访问：https://supabase.com/dashboard
   - 登录你的账户

2. **选择项目**
   - 找到并点击你的 JoyBilliards 项目

3. **获取 Service Role Key**
   - 点击左侧菜单的 **Settings** (⚙️)
   - 点击 **API**
   - 找到 **Project API keys** 部分
   - 找到 **service_role** (标记为 `secret`)
   - 点击 **眼睛图标** 显示完整的 key
   - 点击 **复制图标** 复制这个 key

4. **填入脚本**
   - 打开 `cleanup_auth_users.py`
   - 找到第 27 行：`SERVICE_ROLE_KEY = ""`
   - 将复制的 key 粘贴到引号之间
   - 保存文件

   ```python
   # 修改前
   SERVICE_ROLE_KEY = ""
   
   # 修改后（示例，你的 key 会不同）
   SERVICE_ROLE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   ```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚀 运行脚本

### 方法1：直接运行

```bash
cd /Users/mengyang/Desktop/JoyBilliards
python cleanup_auth_users.py
```

### 方法2：使用 Python3

```bash
python3 cleanup_auth_users.py
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📺 运行示例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 Supabase Auth 孤儿用户清理脚本
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📡 Supabase URL: https://qnwtqgdbgyqwpsdqvxfl.supabase.co
🔑 Service Role Key: eyJhbGciOi...NiIsInR5cCI
📋 待清理邮箱数量: 7

⚠️ 警告：此操作将永久删除 Auth 中的用户记录！

待删除的邮箱列表：
   1. 1042338586@qq.com
   2. 18274802471@163.com
   3. owenchen1839@gmail.com
   4. 976318872@qq.com
   5. mengyang19960220@vip.qq.com
   6. mengyang1990220@gmail.com
   7. admin@joybilliards.local

确认要继续吗？(输入 'YES' 确认): YES

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 开始清理 7 个孤儿用户...

[1/7] 处理: 1042338586@qq.com
   📋 找到用户:
      ID: abc123-def456-ghi789
      创建时间: 2025-10-10T12:00:00Z
   🗑️  正在删除...
   ✅ 删除成功!

[2/7] 处理: 18274802471@163.com
   ℹ️  用户不存在（可能已被删除）

... (继续处理其他用户)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 清理结果汇总
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
总计:       7 个邮箱
✅ 成功删除: 5 个
ℹ️  未找到:   2 个
❌ 删除失败: 0 个
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎉 现在这些邮箱可以重新注册了！
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ✅ 验证清理结果

### 1. 测试注册

让 Bella Zhao 尝试使用 `1042338586@qq.com` 重新注册：

1. 访问网站：https://rank.joybilliards.co.nz/register
2. 填写注册信息
3. 应该能够成功注册并收到确认邮件

### 2. 查看清理队列（可选）

在 Supabase SQL Editor 中运行：

```sql
-- 查看已清理的用户
SELECT * FROM auth_cleanup_queue WHERE cleaned_from_auth = TRUE;

-- 标记所有为已清理（如果脚本成功）
UPDATE auth_cleanup_queue SET cleaned_from_auth = TRUE WHERE cleaned_from_auth = FALSE;
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## ⚠️ 常见问题

### Q1: 提示 "SERVICE_ROLE_KEY 未配置"

**A:** 你需要在脚本中填入 Service Role Key。请按照上面的步骤获取并填入。

### Q2: 提示 "API 错误 (401)"

**A:** Service Role Key 不正确。请重新复制完整的 key（通常很长，100+ 字符）。

### Q3: 提示 "网络错误"

**A:** 检查：
- 网络连接是否正常
- Supabase URL 是否正确
- 防火墙是否阻止了请求

### Q4: 部分用户显示 "未找到"

**A:** 这是正常的！说明这些用户已经在 Auth 中被删除了（可能是 Supabase 自动清理或之前的操作）。

### Q5: 如何添加或删除待清理的邮箱？

**A:** 编辑脚本中的 `EMAILS_TO_DELETE` 列表：

```python
EMAILS_TO_DELETE = [
    "new_email@example.com",  # 添加新邮箱
    # "old_email@example.com",  # 注释掉不需要清理的
]
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔒 安全提示

⚠️ **Service Role Key 是超级管理员密钥！**

1. **永远不要**将它提交到 Git
2. **永远不要**分享给他人
3. **永远不要**在客户端代码中使用
4. 使用完毕后，建议在脚本中删除或用 `****` 替换
5. 如果泄露，立即在 Supabase Dashboard 重新生成

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📞 需要帮助？

如果遇到问题：

1. 检查错误信息
2. 确认 Service Role Key 是否正确
3. 尝试手动在 Supabase Dashboard 删除一个用户测试
4. 联系我获取进一步帮助

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎉 完成后

清理完成后：

1. ✅ 测试 Bella Zhao 的注册
2. ✅ 在脚本中删除或隐藏 Service Role Key
3. ✅ 将脚本提交到 Git（确保 key 已删除）
4. ✅ 通知所有受影响的用户可以重新注册

祝清理顺利！🎱

