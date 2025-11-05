# 🔧 MCP 断开 - 手动操作指南

**状态：** Supabase MCP 工具断开连接  
**原因：** 会话超时或配置问题  
**解决：** 使用手动 SQL 操作

---

## 📋 立即执行（2分钟）

### 第 1 步：打开 Supabase SQL Editor
https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql/new

### 第 2 步：运行诊断 SQL

复制 `fix-leaderboard-now.sql` 的全部内容并运行

或者直接复制这个：

```sql
-- 检查 Sayed 的数据
SELECT 
  name,
  ranking_points,
  loyalty_points,
  ranking_level
FROM users
WHERE name LIKE '%Sayed%';

-- 检查段位积分历史
SELECT 
  points_change,
  reason,
  year,
  month
FROM ranking_point_history
WHERE user_id = (SELECT id FROM users WHERE name LIKE '%Sayed%' LIMIT 1);

-- 重新计算 ranking_points
UPDATE users
SET ranking_points = (
  SELECT COALESCE(SUM(points_change), 0)
  FROM ranking_point_history
  WHERE user_id = users.id
)
WHERE name LIKE '%Sayed%';

-- 验证结果
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM users
WHERE name LIKE '%Sayed%';
```

### 第 3 步：查看结果并告诉我

**把 SQL 执行结果告诉我：**
- Sayed 的 `ranking_points` 是多少？
- Sayed 的 `loyalty_points` 是多少？
- 他有多少条 `ranking_point_history` 记录？

---

## 🎯 可能的情况

### 情况 1：他的 ranking_points 实际上是 22
**说明：** 之前的迁移把消费积分错误地迁移到了段位积分
**解决：** 清零他的 ranking_points
```sql
UPDATE users 
SET ranking_points = 0 
WHERE name LIKE '%Sayed%';
```

### 情况 2：他的 ranking_points = 0，但历史记录有 22
**说明：** ranking_points 没有同步
**解决：** 重新计算
```sql
UPDATE users
SET ranking_points = (
  SELECT COALESCE(SUM(points_change), 0)
  FROM ranking_point_history
  WHERE user_id = users.id
)
WHERE name LIKE '%Sayed%';
```

### 情况 3：前端代码还在读取 loyalty_points
**说明：** 代码逻辑有问题
**解决：** 我已经更新了代码，刷新浏览器后应该修复

---

## 📊 完整修复流程

### 1. 先诊断
运行上面的 SQL，查看 Sayed 的数据

### 2. 清零错误数据
```sql
-- 如果他的 ranking_points 不应该有值
UPDATE users 
SET ranking_points = 0,
    ranking_level = 'beginner'
WHERE name LIKE '%Sayed%';

-- 删除他的错误段位积分历史（如果有）
DELETE FROM ranking_point_history
WHERE user_id = (SELECT id FROM users WHERE name LIKE '%Sayed%' LIMIT 1);
```

### 3. 刷新浏览器
强制刷新：`Cmd+Shift+R`

### 4. 验证
排行榜应该不再显示 Sayed（因为他 ranking_points = 0）

---

## 🚀 快速修复（如果急着用）

**一键清除所有错误的段位积分：**

```sql
-- 确保所有用户的 ranking_points 和历史记录一致
UPDATE users
SET ranking_points = (
  SELECT COALESCE(SUM(points_change), 0)
  FROM ranking_point_history
  WHERE user_id = users.id
);

-- 验证
SELECT 
  name,
  ranking_points,
  loyalty_points
FROM users
WHERE ranking_points > 0 OR loyalty_points > 0
ORDER BY ranking_points DESC
LIMIT 10;
```

---

**运行 SQL 后把结果发给我！** 📊

特别是这几个值：
- Sayed 的 ranking_points
- Sayed 的 loyalty_points
- 他有几条 ranking_point_history 记录


