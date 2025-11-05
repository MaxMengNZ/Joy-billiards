# ⚡ 立即执行这个 SQL！

**问题确认：** Sayed 的 ranking_points = 22（错误！应该是 0）  
**原因：** 之前的迁移把 loyalty_points 错误地复制到了 ranking_points  
**解决：** 清零所有 ranking_points，让你重新输入

---

## 🚀 一键修复（复制→粘贴→运行）

### 打开 Supabase SQL Editor
https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql/new

### 复制粘贴这段代码并点击 RUN：

```sql
-- 清零所有 ranking_points（因为你要重新输入）
UPDATE users 
SET 
  ranking_points = 0,
  ranking_level = 'beginner'
WHERE ranking_points > 0;

-- 清空段位积分历史
DELETE FROM ranking_point_history;

-- 验证
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM users
ORDER BY loyalty_points DESC
LIMIT 10;
```

---

## ✅ 执行后应该看到：

所有用户：
- `ranking_points` = **0** ✅
- `loyalty_points` = 保持不变（22, 40, 30.40 等）✅
- `ranking_level` = **beginner** ✅

---

## 🎯 然后刷新浏览器

访问：http://localhost:3000/leaderboard

**排行榜应该是空的！** ✅

因为所有人的 `ranking_points` 都是 0。

---

## 💡 接下来你可以：

### 重新添加正确的段位积分

使用我之前给你的方法：

```sql
-- 给玩家添加段位积分（不是消费积分！）
SELECT admin_add_ranking_points(
  (SELECT id FROM users WHERE name = '玩家名字'),
  150,  -- 段位积分
  'November 2025 ranking',
  (SELECT id FROM users WHERE role = 'admin' LIMIT 1)
);
```

---

## 📊 总结

### 当前状态：
- ✅ Loyalty points（消费积分）= 正确的
- ❌ Ranking points（段位积分）= 错误的（被污染了）

### 修复后：
- ✅ Loyalty points = 保持不变
- ✅ Ranking points = 全部清零
- ✅ 可以重新输入正确的段位积分

---

**立即运行上面的 SQL，然后告诉我结果！** 🚀

执行后：
1. 所有 ranking_points 应该 = 0
2. 排行榜应该是空的
3. 然后你可以重新输入正确的积分


