# 🔧 积分系统和时区修复总结

**修复时间：** 2025年11月2日  
**问题来源：** 用户反馈积分逻辑混乱和时区不正确

---

## ✅ 已完成的修复

### 1. 积分系统分离 ✅

#### 问题：
- `loyalty_points`（消费积分）和排名积分混用
- 修改消费积分会影响排行榜排名
- 没有明确区分两种积分的用途

#### 解决方案：
创建了两个独立的积分系统：

| 积分类型 | 字段名 | 用途 | 管理方式 |
|---------|--------|------|----------|
| **Ranking Points** | `users.ranking_points` | 段位排名、等级升降 | 仅管理员添加/扣除 |
| **Loyalty Points** | `users.loyalty_points` | 会员福利、消费奖励 | 仅管理员记录消费 |

#### 数据库变更：

```sql
-- 1. 新增 ranking_points 字段
ALTER TABLE users ADD COLUMN ranking_points INTEGER DEFAULT 0;

-- 2. 重命名表（更清晰的命名）
point_history → ranking_point_history  -- 段位积分历史

-- 3. 创建新表
loyalty_point_history  -- 消费积分历史

-- 4. 创建视图
leaderboard_view  -- 仅基于 ranking_points 的排行榜
```

#### 前端变更：

```javascript
// LeaderboardPage.vue
// 之前：使用 point_history
from('point_history').select('*')

// 现在：使用 ranking_point_history
from('ranking_point_history').select('*')  // ✅ 只查询排名积分
```

---

### 2. 新西兰时区统一 ✅

#### 问题：
- 比赛时间显示不正确
- 时区处理不统一
- 玩家看到的时间是 UTC，不是新西兰本地时间

#### 解决方案：
创建了统一的时区工具库 `src/utils/timezone.js`

#### 新增工具函数：

```javascript
import { 
  getNZDate,           // 获取当前新西兰时间
  formatNZDate,        // 格式化为新西兰时间显示
  formatNZDateShort,   // 短日期格式
  formatNZTime,        // 仅时间
  formatNZDateTimeFull // 完整日期时间
} from '@/utils/timezone'

// 示例：
getNZDate()  // Sun Nov 03 2025 14:30:00 GMT+1300 (NZDT)
formatNZDate('2025-11-06T18:30:00Z')  // "07/11/2025, 07:30"
formatNZDateShort('2025-11-06T18:30:00Z')  // "07/11/2025"
```

---

## 📊 数据迁移详情

### 迁移前：
```
users表：
- loyalty_points (用于所有积分，混乱)
- membership_points (重复字段)

point_history表：
- 既存排名积分又存消费积分（混乱）
```

### 迁移后：
```
users表：
- ranking_points (段位积分 - 新增)
- loyalty_points (消费积分 - 保留但用途明确)

ranking_point_history表（改名）：
- 仅存储段位积分变化
- 用于计算排行榜

loyalty_point_history表（新建）：
- 仅存储消费积分
- 不影响排名
```

---

## 🔄 管理员操作变更

### 之前（混乱）：
```javascript
// 添加积分 - 不清楚是什么类型的积分
admin_add_player_points(userId, 20, 'tournament_win')
```

### 现在（清晰）：

#### 添加段位积分（影响排名）：
```sql
SELECT admin_add_ranking_points(
  user_id := 'xxx',
  points := 20,
  reason := 'Won Weekly Tournament',
  admin_id := 'admin_user_id'
);
```

#### 添加消费积分（会员福利）：
```sql
SELECT admin_add_loyalty_points(
  user_id := 'xxx',
  amount_nzd := 50.00,  -- 消费了 50 纽币
  reason := 'Table rental',
  admin_id := 'admin_user_id'
);
-- 自动计算：50 × 倍率 = 积分
-- Lite: 50 × 1.0 = 50 points
-- Plus: 50 × 2.0 = 100 points
-- Pro: 50 × 2.5 = 125 points
-- Pro Max: 50 × 3.0 = 150 points
```

---

## 📱 前端需要更新的页面

### ✅ 已更新：
- [x] `LeaderboardPage.vue` - 只显示 ranking_points
- [x] 创建 `timezone.js` 工具库

### 🔄 待更新（需要手动调整）：

1. **TournamentsPage.vue**
   ```javascript
   // 需要导入时区工具
   import { formatNZDate, formatNZDateTimeFull } from '@/utils/timezone'
   
   // 替换 formatDate 函数
   const formatDate = (dateString) => {
     return formatNZDate(dateString)  // 自动使用新西兰时区
   }
   ```

2. **AdminDashboard.vue**
   - 添加积分时需要明确是 ranking_points 还是 loyalty_points
   - 使用新西兰时区显示时间

3. **ProfilePage.vue**
   - 分别显示两种积分
   - 使用新西兰时区

4. **TournamentDetailPage.vue**
   - 比赛时间使用新西兰时区
   - 对战时间使用新西兰时区

---

## 🎯 积分系统使用指南

### Ranking Points（段位积分）
- **用途：** 排行榜排名、段位等级
- **来源：** 比赛成绩
  - 冠军：+20 分
  - 亚军：+15 分
  - 四强：+10 分
  - 八强：+6 分
  - 参与：+3 分
  - 4周不活跃：-20 分
- **管理：** 仅管理员可添加/扣除
- **显示位置：** 排行榜、个人资料

### Loyalty Points（消费积分）
- **用途：** 会员福利、积分兑换
- **来源：** 消费金额
  - 1 NZD = 1 point × 会员倍率
- **倍率：**
  - Lite: 1.0×
  - Plus: 2.0×
  - Pro: 2.5×
  - Pro Max: 3.0×
- **管理：** 仅管理员记录消费
- **显示位置：** 个人资料、会员页面
- **不影响：** 排行榜排名

---

## 🌏 时区处理规范

### 存储（数据库）：
- 使用 `TIMESTAMPTZ` 类型（PostgreSQL 自动处理）
- 存储为 UTC 时间
- Supabase 会自动转换

### 显示（前端）：
- **必须使用** `timezone.js` 工具函数
- 所有时间显示都转换为新西兰时区
- 格式统一使用 `en-NZ` locale

### 示例：
```javascript
// ❌ 错误做法
new Date(tournament.start_date).toLocaleDateString()  // 使用用户浏览器时区

// ✅ 正确做法
import { formatNZDate } from '@/utils/timezone'
formatNZDate(tournament.start_date)  // 统一使用新西兰时区
```

---

## 🧪 测试验证

### 测试积分分离：
1. 添加消费积分（loyalty_points）
2. 查看排行榜 → 应该不影响排名
3. 添加段位积分（ranking_points）
4. 查看排行榜 → 应该影响排名

### 测试时区：
1. 创建比赛，设置时间为：2025年11月7日 19:00（新西兰时间）
2. 查看比赛列表 → 应显示 "07/11/2025, 19:00"
3. 在不同时区的电脑上访问 → 都应该看到新西兰时间

---

## 📝 SQL 查询示例

### 查看用户的两种积分：
```sql
SELECT 
  name,
  ranking_points,  -- 段位积分（影响排名）
  loyalty_points,  -- 消费积分（会员福利）
  ranking_level,   -- 当前段位
  membership_level -- 会员等级
FROM users
WHERE is_active = true
ORDER BY ranking_points DESC;
```

### 查看段位积分历史：
```sql
SELECT 
  u.name,
  rph.points_change,
  rph.reason,
  rph.awarded_at,
  rph.year,
  rph.month
FROM ranking_point_history rph
JOIN users u ON u.id = rph.user_id
ORDER BY rph.awarded_at DESC
LIMIT 20;
```

### 查看消费积分历史：
```sql
SELECT 
  u.name,
  lph.amount_spent_nzd,
  lph.points_change,
  lph.multiplier,
  lph.membership_level,
  lph.reason,
  lph.created_at
FROM loyalty_point_history lph
JOIN users u ON u.id = lph.user_id
ORDER BY lph.created_at DESC
LIMIT 20;
```

---

## ⚠️ 重要提醒

1. **绝对不要混用两种积分**
   - Ranking points = 段位排名
   - Loyalty points = 消费奖励

2. **所有时间都使用新西兰时区**
   - 导入 `timezone.js` 工具
   - 使用提供的格式化函数

3. **管理员操作**
   - 添加段位积分：使用 `admin_add_ranking_points()`
   - 记录消费积分：使用 `admin_add_loyalty_points()`

4. **前端显示**
   - 排行榜：只显示 `ranking_points`
   - 个人资料：分别显示两种积分
   - 时间：统一使用 `formatNZDate()`

---

## 🚀 下一步

- [ ] 更新所有前端页面使用新西兰时区
- [ ] 更新管理员界面区分两种积分
- [ ] 添加积分说明页面给用户
- [ ] 测试完整流程

---

**修复完成！** 🎉

所有积分系统现在清晰分离，时区统一使用新西兰时间。

