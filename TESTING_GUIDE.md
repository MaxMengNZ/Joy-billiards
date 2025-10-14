# 🧪 完整测试指南

## 📋 测试计划

---

## 一、玩家测试（用 Bella 账号）

### **账号信息：**
```
Email: 1042338586@qq.com
Password: (你的密码)
角色：🎯 Player
会员卡：JB-2025-496525
段位：⚪ Beginner
```

---

### 测试1：查看个人资料和会员卡

1. **登录 Bella 账号**
   - 访问 http://localhost:3000/login
   - 输入邮箱和密码

2. **点击导航栏的 "👤 bella zhao"**

3. **应该看到：**
   - ✅ 🥉 Bronze 会员卡（青铜色）
   - ✅ 会员卡号：JB-2025-496525
   - ✅ Bronze Member 福利列表
   - ✅ 段位：⚪ Beginner
   - ✅ 统计：0胜0负

---

### 测试2：查看排行榜

1. **点击导航栏 "🏆 Rankings"**

2. **应该看到：**
   - ✅ Top 3 领奖台（Max, Michael, John）
   - ✅ 完整排名表
   - ✅ 你的名字在列表中（最后，0分）
   - ✅ 段位系统说明
   - ✅ 积分规则

---

### 测试3：浏览比赛（玩家权限）

1. **点击 "Tournaments"**

2. **应该看到：**
   - ✅ 可以看到所有比赛
   - ❌ **没有** "Create Tournament" 按钮
   - ❌ **没有** "Edit" 按钮
   - ❌ **没有** "Delete" 按钮
   - ✅ **只有** "View Details" 按钮

---

### 测试4：报名比赛

1. **点击某个比赛的 "View Details"**

2. **应该看到：**
   - ✅ 比赛详细信息
   - ✅ "Register" 按钮（绿色）
   - ❌ **没有** "Add Player" 按钮（管理员专属）
   - ❌ **没有** "Schedule Match" 按钮（管理员专属）

3. **点击 "Register" 按钮**
   - ✅ 提示 "Successfully registered for tournament!"
   - ✅ 按钮变为 "✅ Registered"
   - ✅ 出现 "Cancel Registration" 按钮
   - ✅ 在报名列表中看到你的名字

4. **查看报名列表**
   - ✅ 显示你的名字
   - ✅ 显示你的段位徽章 ⚪
   - ✅ 显示你的积分和战绩
   - ❌ **没有** "Remove" 按钮（你不是管理员）

---

### 测试5：取消报名

1. **点击 "Cancel Registration" 按钮**

2. **确认对话框**

3. **应该看到：**
   - ✅ 提示 "Registration cancelled"
   - ✅ 按钮恢复为 "Register"
   - ✅ "Cancel Registration" 按钮消失
   - ✅ 从报名列表移除

---

### 测试6：权限限制

**尝试访问这些页面：**

1. `/players` - ❌ 自动跳转到首页
2. `/admin` - ❌ 自动跳转到首页
3. `/weekly-tournament` - ❌ 自动跳转到首页

**导航栏应该看到：**
```
[Home] [🏆 Rankings] [Tournaments] [Matches] | 👤 bella zhao [Logout]
```

**不应该看到：**
- ❌ Players 链接
- ❌ Admin 链接

---

## 二、管理员测试（用 Max 账号）

### **账号信息：**
```
Email: maxmengnz@qq.com
Password: (你的密码)
角色：👑 Administrator
会员卡：JB-2025-574646
段位：👑 Hall of Fame (殿堂)
```

---

### 测试7：管理员功能访问

**登录后，导航栏应该看到：**
```
[Home] [🏆 Rankings] [Tournaments] [Matches] [Players] [Admin]
                                                  ↑        ↑
                                            管理员专属
                                            
👤 Max Meng 👑 [Logout]
```

---

### 测试8：创建比赛

1. **访问 `/tournaments`**

2. **应该看到：**
   - ✅ "Create Tournament" 按钮（绿色）

3. **点击 "Create Tournament"**

4. **填写信息：**
   ```
   Name: Weekend Championship
   Type: Single Elimination
   Description: Test tournament
   Start Date: (选择未来日期)
   Max Players: 8
   Entry Fee: 10
   Prize Pool: 100
   Status: Registration
   ```

5. **点击 "Create"**
   - ✅ 比赛创建成功
   - ✅ 出现在列表中

---

### 测试9：编辑和删除比赛

1. **在比赛列表中**

2. **应该看到每个比赛有：**
   - ✅ "View Details" 按钮
   - ✅ "Edit" 按钮（管理员专属）
   - ✅ "Delete" 按钮（管理员专属）

3. **点击 "Edit"** 
   - 修改比赛信息
   - 保存

4. **点击 "Delete"**
   - 确认删除
   - 比赛从列表移除

---

### 测试10：管理报名玩家

1. **进入比赛详情**

2. **应该看到：**
   - ✅ "Add Player" 按钮
   - ✅ "Schedule Match" 按钮

3. **点击 "Add Player"**
   - 选择玩家
   - 添加到比赛

4. **在报名列表中**
   - ✅ 每个玩家有 "Remove" 按钮
   - 点击可移除玩家

---

### 测试11：安排对战

1. **点击 "Schedule Match"**

2. **填写：**
   ```
   Round: 1
   Match: 1
   Player 1: (选择)
   Player 2: (选择)
   Table: 1
   ```

3. **点击 "Create"**
   - ✅ 对战创建成功

4. **在对战列表中点击 "Update Score"**
   - 更新状态为 Completed
   - 输入比分
   - 选择胜者
   - ✅ 玩家统计自动更新

---

## 三、性能测试

### 测试12：加载速度

1. **硬刷新页面：Cmd + Shift + R**

2. **测试页面切换速度：**
   - Home → Rankings ⚡ 应该瞬间
   - Rankings → Tournaments ⚡ 应该瞬间
   - Tournaments → Matches ⚡ 应该瞬间

3. **预期速度：**
   - 首次加载：< 1秒
   - 页面切换：< 0.3秒
   - 数据加载：< 0.5秒

---

## 四、功能对比表

| 功能 | 管理员 | 玩家 | 游客 |
|------|--------|------|------|
| 查看比赛列表 | ✅ | ✅ | ✅ |
| 创建比赛 | ✅ | ❌ | ❌ |
| 编辑比赛 | ✅ | ❌ | ❌ |
| 删除比赛 | ✅ | ❌ | ❌ |
| 报名比赛 | ✅ | ✅ | ❌ |
| 取消报名 | ✅ | ✅ | ❌ |
| 添加玩家 | ✅ | ❌ | ❌ |
| 移除玩家 | ✅ | ❌ | ❌ |
| 安排对战 | ✅ | ❌ | ❌ |
| 更新比分 | ✅ | ❌ | ❌ |
| 查看排行榜 | ✅ | ✅ | ✅ |
| 查看个人资料 | ✅ | ✅ | ❌ |
| 查看Players页面 | ✅ | ❌ | ❌ |
| 访问Admin页面 | ✅ | ❌ | ❌ |

---

## 五、测试检查清单

### ✅ 必须测试的功能

#### 作为玩家（Bella）：
- [ ] 登录成功
- [ ] 查看会员卡（有卡号）
- [ ] 查看排行榜
- [ ] 浏览比赛（无Create按钮）
- [ ] 报名比赛（Register按钮）
- [ ] 取消报名
- [ ] 不能访问 /players
- [ ] 不能访问 /admin

#### 作为管理员（Max）：
- [ ] 创建比赛
- [ ] 编辑比赛
- [ ] 删除比赛
- [ ] 手动添加玩家
- [ ] 移除玩家
- [ ] 安排对战
- [ ] 更新比分
- [ ] 访问所有页面

#### 性能测试：
- [ ] 硬刷新 < 1秒
- [ ] 页面切换瞬间
- [ ] 无卡顿

---

## 六、问题排查

### 如果看不到会员卡：
1. 退出登录
2. 重新登录
3. 访问 /profile

### 如果报名按钮不显示：
1. 检查比赛状态是否为 "Registration"
2. 检查是否已满员
3. 检查是否已登录

### 如果管理员功能不显示：
1. 确认角色为 admin
2. 重新登录
3. 检查浏览器控制台错误

---

## 🎊 完成状态

```
✅ 用户系统：完整
✅ 认证系统：完整
✅ 会员卡系统：自动发放
✅ 段位系统：完整
✅ 排行榜：完整
✅ 比赛管理：权限控制
✅ 报名系统：玩家自主
✅ 对战系统：管理员控制
✅ 权限隔离：严格

系统状态：🟢 完全就绪！
```

---

**开始测试吧！** 🚀

用 Bella 的账号试试报名功能！

