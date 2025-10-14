# 🗑️ 数据库清理计划

## 📊 当前数据概况
- **总用户数**: 29人 (2个管理员 + 27个玩家)
- **比赛数**: 2个
- **比赛记录**: 45条
- **积分记录**: 30条
- **忠诚积分**: 5条

## 🎯 清理策略

### ✅ 保留的数据
1. **管理员账号** (2个)
   - `Max Meng` (maxmengnz@qq.com) - 你的主账号
   - `Admin User` (admin@joybilliards.local) - 系统管理员

2. **真实用户账号** (建议保留)
   - 看起来像真实用户的账号，如：
     - `Chuiqiang Meng` (mengyang1990220@gmail.com)
     - `yangmeng` (976318872@qq.com)
     - `owenchen1839` (owenchen1839@gmail.com)

### ❌ 可以删除的测试数据
1. **明显测试账号**
   - `Test Manual User` (test-manual@example.com)
   - 其他以 `@test.com` 结尾的账号

2. **测试比赛数据**
   - 所有比赛记录 (2个比赛)
   - 所有比赛结果 (45条记录)

3. **测试积分数据**
   - 测试用户的积分记录
   - 测试忠诚积分记录

## 🔧 清理方案选择

### 方案A: 保守清理 (推荐)
- 保留所有管理员账号
- 保留看起来像真实用户的账号
- 删除明显的测试账号
- 删除所有比赛和积分数据
- 重置所有用户的统计为初始状态

### 方案B: 激进清理
- 只保留你的管理员账号
- 删除所有其他用户
- 删除所有比赛和积分数据
- 完全清空数据库

### 方案C: 保留现有数据
- 保留所有数据
- 仅清理明显重复或错误的记录

## 💡 推荐操作

**建议采用方案A (保守清理)**，原因：
1. 保留真实用户，避免误删
2. 清理测试数据，保持系统干净
3. 重置统计，让用户重新开始
4. 保持系统完整性

## 🚀 执行步骤

### 步骤1: 备份数据
```sql
-- 导出用户列表
SELECT * FROM users WHERE role = 'admin';
```

### 步骤2: 清理测试数据
```sql
-- 删除测试比赛
DELETE FROM matches WHERE tournament_id IN (
  SELECT id FROM tournaments WHERE name LIKE '%test%' OR name LIKE '%Test%'
);

-- 删除测试比赛
DELETE FROM tournaments WHERE name LIKE '%test%' OR name LIKE '%Test%';

-- 删除测试用户
DELETE FROM users WHERE email LIKE '%@test.com' OR name LIKE '%Test%';

-- 重置所有用户统计
UPDATE users SET 
  wins = 0, 
  losses = 0, 
  break_and_run_count = 0,
  current_year_points = 0,
  loyalty_points = 0;

-- 清空积分历史
DELETE FROM point_history;

-- 清空忠诚积分
DELETE FROM loyalty_points;
```

### 步骤3: 验证清理结果
- 检查管理员账号是否保留
- 确认测试数据已删除
- 验证系统功能正常

## ⚠️ 注意事项
1. **执行前务必备份**
2. **分批执行，逐步验证**
3. **保留管理员权限**
4. **测试系统功能**

## 🎯 清理后的预期结果
- 用户数: 2-5个 (管理员 + 真实用户)
- 比赛数: 0
- 比赛记录: 0
- 积分记录: 0
- 忠诚积分: 0

这样你就有了一个干净的系统，可以开始正式运营！
