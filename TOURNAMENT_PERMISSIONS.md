# 🏆 Tournament Permissions & Registration System

## 🔐 权限划分 / Permission Structure

---

## 一、管理员权限 / Admin Permissions 👑

### ✅ **比赛管理 / Tournament Management**

**创建比赛 / Create Tournaments:**
- 点击 "Create Tournament" 按钮
- 设置比赛信息、日期、奖金等
- 只有管理员能看到此按钮

**编辑比赛 / Edit Tournaments:**
- 每个比赛卡片上的 "Edit" 按钮
- 修改比赛详情
- 只有管理员能看到此按钮

**删除比赛 / Delete Tournaments:**
- 每个比赛卡片上的 "Delete" 按钮
- 永久删除比赛
- 只有管理员能看到此按钮

**添加参与者 / Add Participants:**
- 在比赛详情页点击 "Add Player"
- 手动添加玩家到比赛
- 只有管理员能操作

**移除参与者 / Remove Participants:**
- 参与者卡片上的 "Remove" 按钮
- 移除已报名的玩家
- 只有管理员能看到

**安排对战 / Schedule Matches:**
- "Schedule Match" 按钮
- 创建对战记录
- 只有管理员能操作

**更新比分 / Update Scores:**
- 对战卡片上的 "Update Score" 按钮
- 记录比分和胜者
- 只有管理员能操作

---

## 二、玩家权限 / Player Permissions 🎯

### ✅ **可以做的 / Allowed Actions**

**浏览比赛 / Browse Tournaments:**
- ✅ 查看所有比赛列表
- ✅ 查看比赛详情
- ✅ 查看报名人数
- ✅ 查看比赛状态

**报名比赛 / Register for Tournaments:**
- ✅ 点击 "Register" 按钮
- ✅ 一键报名参赛
- ✅ 条件：比赛状态为 "Registration" 或 "Upcoming"
- ✅ 条件：比赛未满员

**取消报名 / Cancel Registration:**
- ✅ 点击 "Cancel Registration" 按钮
- ✅ 取消自己的报名
- ✅ 只能在比赛开始前取消

**查看对战 / View Matches:**
- ✅ 查看比赛对战表
- ✅ 查看比分和结果
- ✅ 查看自己的对战安排

### ❌ **不能做的 / Not Allowed**

- ❌ 创建比赛
- ❌ 编辑比赛信息
- ❌ 删除比赛
- ❌ 添加其他玩家
- ❌ 移除其他玩家
- ❌ 安排对战
- ❌ 更新比分

---

## 三、未登录用户 / Guest Users 🌐

### ✅ **可以做的 / Allowed Actions**

- ✅ 浏览所有比赛
- ✅ 查看比赛详情
- ✅ 查看对战记录
- ✅ 查看排行榜

### ❌ **不能做的 / Not Allowed**

- ❌ 报名比赛（需要先注册账号）
- ❌ 查看玩家详细信息
- ❌ 任何管理功能

---

## 四、报名系统 / Registration System

### 🎯 **玩家报名流程 / Player Registration Flow**

#### 第1步：浏览比赛
1. 访问 http://localhost:3000/tournaments
2. 查看所有比赛
3. 找到想参加的比赛

#### 第2步：查看详情
1. 点击 "View Details"
2. 查看比赛信息
3. 查看已报名玩家
4. 查看是否还有名额

#### 第3步：报名
1. 点击 "Register" 按钮
2. 系统自动添加到报名列表
3. 显示 "✅ Registered"

#### 第4步：取消（可选）
1. 如果改变主意，点击 "Cancel Registration"
2. 确认取消
3. 从报名列表移除

---

### 👑 **管理员添加玩家流程 / Admin Add Player Flow**

#### 手动添加
1. 进入比赛详情
2. 点击 "Add Player"
3. 选择玩家
4. 玩家添加到报名列表

#### 移除玩家
1. 在报名列表中找到玩家
2. 点击 "Remove" 按钮
3. 确认移除

---

## 五、报名条件 / Registration Conditions

### ✅ **可以报名的情况：**

1. **比赛状态正确：**
   - Status = "Registration" (开放报名)
   - Status = "Upcoming" (即将开始)

2. **有名额：**
   - 当前报名人数 < Max Players
   - 或没有设置人数限制

3. **已登录：**
   - 必须有账号并登录

4. **未重复报名：**
   - 每人每个比赛只能报名一次

### ❌ **不能报名的情况：**

1. 比赛已开始 (Status = "In Progress")
2. 比赛已结束 (Status = "Completed")
3. 比赛已满员
4. 未登录
5. 已经报名过了

---

## 六、UI 差异 / UI Differences

### 管理员看到的比赛卡片：
```
📋 Tournament Name
[View Details] [Edit] [Delete]
     ↑           ↑       ↑
   所有人      仅管理员  仅管理员
```

### 玩家看到的比赛卡片：
```
📋 Tournament Name
[View Details]
     ↑
   所有人都能看到
```

### 比赛详情页 - 管理员：
```
👥 Registered Players (5)
[Add Player]  ← 管理员专属

⚔️ Matches (3)
[Schedule Match]  ← 管理员专属

每场比赛显示 [Update Score] ← 管理员专属
```

### 比赛详情页 - 已报名玩家：
```
👥 Registered Players (5)
[✅ Registered] [Cancel Registration]
      ↑                  ↑
   已报名状态        取消报名按钮

⚔️ Matches (3)
（只能查看，不能操作）
```

### 比赛详情页 - 未报名玩家：
```
👥 Registered Players (5)
[Register]
    ↑
  报名按钮

⚔️ Matches (3)
（只能查看）
```

---

## 七、数据库结构 / Database Structure

### tournament_registrations 表

```sql
- id: UUID (主键)
- tournament_id: UUID (比赛ID)
- user_id: UUID (用户ID)
- registered_at: TIMESTAMP (报名时间)
- status: VARCHAR (状态: registered/cancelled/confirmed)
```

### RLS 策略

```
✅ 所有人可以查看报名信息
✅ 玩家可以报名自己
✅ 玩家可以取消自己的报名
✅ 管理员可以管理所有报名
```

---

## 八、测试场景 / Test Scenarios

### 测试1：玩家报名流程

**用 Bella 的账号：**
1. 登录：1042338586@qq.com
2. 访问 `/tournaments`
3. 看到比赛卡片上**只有** "View Details" 按钮
4. 点击进入比赛详情
5. 点击 "Register" 按钮
6. ✅ 报名成功
7. 按钮变为 "✅ Registered"
8. 看到 "Cancel Registration" 按钮

### 测试2：玩家取消报名

1. 继续上面的步骤
2. 点击 "Cancel Registration"
3. 确认取消
4. ✅ 从报名列表移除
5. 按钮恢复为 "Register"

### 测试3：管理员管理比赛

**用 Max 的账号：**
1. 登录：maxmengnz@qq.com
2. 访问 `/tournaments`
3. 看到 **"Create Tournament"** 按钮
4. 每个比赛卡片有 **"Edit"** 和 **"Delete"** 按钮
5. 进入比赛详情
6. 看到 **"Add Player"** 和 **"Schedule Match"** 按钮
7. 可以手动添加玩家
8. 可以移除任何已报名的玩家
9. 可以安排对战和更新比分

---

## 九、安全措施 / Security Measures

### 数据库级别

- ✅ RLS 策略防止未授权操作
- ✅ 玩家只能报名/取消自己
- ✅ 管理员权限通过数据库验证

### 应用级别

- ✅ UI 根据角色动态显示按钮
- ✅ 路由守卫保护管理页面
- ✅ 双重验证（前端+后端）

---

## 十、当前状态 / Current Status

```
数据库表：
✅ users (7个用户)
✅ tournaments (2个比赛)
✅ matches (0场对战)
✅ tournament_registrations (0条报名) ← 新增！

权限系统：
✅ 管理员完全控制
✅ 玩家自主报名
✅ UI 动态显示

功能状态：
✅ 创建比赛 - 仅管理员
✅ 编辑比赛 - 仅管理员
✅ 删除比赛 - 仅管理员
✅ 玩家报名 - 所有玩家
✅ 取消报名 - 已报名玩家
✅ 添加玩家 - 仅管理员
✅ 移除玩家 - 仅管理员
✅ 安排对战 - 仅管理员
✅ 更新比分 - 仅管理员
```

---

## 🎉 权限系统完成！

所有功能都已按照要求配置：
- 👑 管理员：完全控制
- 🎯 玩家：浏览和报名
- 🌐 游客：仅浏览

立即测试吧！🚀

