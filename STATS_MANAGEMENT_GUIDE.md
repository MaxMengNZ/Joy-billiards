# 📊 Statistics Management System

## 🎉 新功能总览

我们为主页添加了两个重要功能：

1. **✅ 实时自动刷新** - 统计数据每30秒自动更新
2. **✅ 管理员手动修改** - 管理员可以手动修正「Tournaments Held」统计（线下比赛也能被统计进来）

> ℹ️ **2025-11-12 更新**
>
> - 目前支持的手动覆盖对象：`Tournaments Held`
> - 覆盖值存储在 `site_stats_overrides` 表，访客只能读取，只有管理员可以通过 `admin_set_stat_override` RPC 修改
> - 点击 Admin Dashboard → System Statistics Management → “Add Offline Count” 即可填写线下比赛数量或恢复自动统计

---

## 📈 功能 1: 实时自动刷新

### **主页统计卡片**

主页现在显示三个统计数据：
- 👥 **Registered Players** - 注册玩家总数
- 🏆 **Tournaments Held** - 举办的比赛总数
- ⚔️ **Matches Played** - 对局总数

### **自动刷新机制**

```javascript
✅ 页面加载时立即获取最新数据
✅ 每30秒自动刷新一次
✅ 离开页面时自动停止刷新（节省资源）
✅ 使用响应式数据，无需手动刷新页面
```

### **数据来源**

默认情况下，统计数据**自动从数据库计算**：
- Players: `SELECT COUNT(*) FROM users`
- Tournaments: `SELECT COUNT(*) FROM tournaments`
- Matches: `SELECT COUNT(*) FROM matches`

---

## 🛠️ 功能 2: 管理员手动修改

### **访问路径**

1. 登录管理员账号
2. 进入 `Admin Dashboard`
3. 滚动到底部 - **📈 System Statistics Management** 部分

### **统计管理界面**

每个统计项显示：
- **大号数字** - 当前显示在主页的数值
- **徽章** - 显示当前模式
  - 🔄 **Auto-Count** - 自动计算（绿色）
  - ✏️ **Manual Override** - 手动覆盖（黄色）
- **操作按钮**
  - 🟦 **Add Offline Count** - 仅在「Tournaments Held」上可见，用于输入线下赛事
  - 🔄 **Reset to Auto** - 恢复自动计算

> 📌 目前只有「Tournaments Held」开放手动覆盖入口，其它统计项仍保持全自动计算。

---

## 📝 使用场景

### **场景 1: 正常使用（默认）**

**状态**: 🔄 Auto-Count Mode

系统自动从数据库计算统计数据，主页每30秒更新一次。

**无需任何操作！**

---

### **场景 2: 数据修正（手动覆盖）**

**何时使用**:
- ✅ 数据库迁移后需要调整计数
- ✅ 删除了垃圾数据但想保留历史总数
- ✅ 有线下比赛未录入系统但想计入总数
- ✅ 测试数据清理后恢复真实数值

**步骤**:

1. **点击 ✏️ Edit 按钮**

2. **编辑数值**
   - 输入新的数值（必须 ≥ 0）
   - 选择模式：
     - 🔄 Auto-Count: 使用数据库计数
     - ✏️ Manual Override: 使用自定义数值
   - （可选）填写备注说明原因

3. **预览**
   - 系统会显示 "Homepage will show XX"
   - 如果是手动模式，会显示警告提示

4. **保存**
   - 点击 "💾 Save Changes"
   - 确认操作
   - ✅ 成功后主页立即更新

---

### **场景 3: 恢复自动计算**

**何时使用**:
- 之前手动修改过，现在想恢复自动计算
- 数据库已经清理完成，可以使用真实计数了

**步骤**:

1. 点击 **🔄 Reset to Auto** 按钮
2. 确认操作
3. ✅ 系统恢复使用数据库计数

或者：

1. 点击 **✏️ Edit**
2. 选择模式为 **🔄 Auto-Count**
3. 保存

---

## 💡 实际操作示例

### **示例 1: 修正 Matches Played**

**背景**: 数据库中有45场对局，但你想显示为50（包含5场线下比赛）

**操作**:
```
1. 进入 Admin Dashboard
2. 找到 "⚔️ Matches Played" 卡片
3. 点击 "✏️ Edit"
4. 输入数值: 50
5. 选择: ✏️ Manual Override
6. 备注: "Added 5 offline matches held in September"
7. 保存
```

**结果**: 
- 主页显示 "50" Matches Played
- 卡片显示 "✏️ Manual Override" 徽章
- 显示 "Actual DB Count: 45"（管理员可见）

---

### **示例 2: 恢复自动计算**

**背景**: 之前手动设置为50，现在已经录入那5场比赛，想恢复自动

**操作**:
```
1. 找到 "⚔️ Matches Played" 卡片
2. 点击 "🔄 Reset to Auto"
3. 确认
```

**结果**: 
- 主页显示数据库真实计数（现在是50）
- 卡片显示 "🔄 Auto-Count" 徽章
- 以后新增对局会自动更新计数

---

## 🔐 权限控制

### **查看权限**
- ✅ **所有人** - 可以在主页看到统计数据
- ✅ **所有人** - 数据每30秒自动刷新

### **编辑权限**
- ❌ **普通用户** - 无法访问 Admin Dashboard
- ✅ **管理员** - 可以查看和编辑所有统计数据
- ✅ **管理员** - 可以在手动/自动模式之间切换

---

## 📊 数据库结构

### **system_stats 表**

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | UUID | 主键 |
| `stat_key` | VARCHAR(50) | 统计项标识 (total_players, total_tournaments, total_matches) |
| `stat_value` | INTEGER | 统计值 |
| `is_manual_override` | BOOLEAN | 是否手动覆盖 |
| `last_updated_at` | TIMESTAMPTZ | 最后更新时间 |
| `updated_by` | UUID | 更新者 ID（外键→users） |
| `notes` | TEXT | 备注说明 |
| `created_at` | TIMESTAMPTZ | 创建时间 |

---

## 🎯 最佳实践

### ✅ **推荐**:
1. **优先使用自动模式** - 保持数据一致性
2. **手动修改时填写备注** - 方便追溯原因
3. **定期检查** - 确保手动值仍然合理
4. **修正后恢复自动** - 一旦问题解决，恢复自动模式

### ❌ **避免**:
1. **长期使用手动模式** - 会导致数据不准确
2. **频繁修改** - 可能让用户困惑
3. **无备注的修改** - 其他管理员不知道原因
4. **随意输入数值** - 确保数值有意义

---

## 🔧 技术细节

### **前端实现**

#### HomePage.vue
```javascript
// 使用 statsStore 管理统计数据
const statsStore = useStatsStore()

// 计算属性自动响应数据变化
const stats = computed(() => ({
  totalPlayers: statsStore.totalPlayers,
  totalTournaments: statsStore.totalTournaments,
  totalMatches: statsStore.totalMatches
}))

// 页面加载时启动自动刷新
onMounted(async () => {
  await statsStore.fetchStats()
  statsStore.startAutoRefresh(30000) // 30秒
})

// 页面卸载时停止刷新
onUnmounted(() => {
  statsStore.stopAutoRefresh()
})
```

#### AdminDashboard.vue
```javascript
// 管理员可以编辑统计数据
const openStatEditor = (key, title) => {
  // 打开编辑器
}

const saveStatValue = async () => {
  // 保存到数据库
  await statsStore.updateStat(...)
}

const resetStatToAuto = async (statKey) => {
  // 恢复自动模式
  await statsStore.resetToAutomatic(statKey)
}
```

### **后端实现**

#### 数据库函数
```sql
-- 更新统计数据
CREATE FUNCTION update_system_stat(
  p_stat_key VARCHAR,
  p_stat_value INTEGER,
  p_is_manual BOOLEAN,
  p_notes TEXT
)
```

#### RLS 策略
```sql
-- 所有人可以查看
CREATE POLICY "Anyone can view stats" 
  FOR SELECT USING (true)

-- 只有管理员可以更新
CREATE POLICY "Admins can update stats" 
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users 
            WHERE users.id = auth.uid() 
            AND users.role = 'admin')
  )
```

---

## 📱 用户体验

### **主页访客**
1. 打开主页 → 看到最新统计数据
2. 等待30秒 → 数据自动刷新（无感知）
3. 刷新页面 → 立即获取最新数据

### **管理员**
1. 进入 Admin Dashboard
2. 看到三张卡片，每张显示：
   - 当前值（大号）
   - 模式徽章（绿色/黄色）
   - 实际DB计数（如果有差异）
3. 点击 Edit → 弹出模态框
4. 修改 → 实时预览
5. 保存 → 主页立即更新
6. 需要时 → 一键恢复自动模式

---

## 🐛 常见问题

### Q1: 主页数据没有实时更新？

**A**: 检查以下几点：
- ✅ 页面是否已经打开超过30秒？
- ✅ 浏览器控制台是否有错误？
- ✅ 管理员是否设置了手动覆盖？

### Q2: 手动设置后想恢复自动，但按钮不见了？

**A**: 重新进入编辑器，选择 "🔄 Auto-Count" 模式即可。

### Q3: 修改后其他管理员能看到吗？

**A**: 能！修改会保存在数据库中，所有管理员都能看到最新值和备注。

### Q4: 可以设置负数吗？

**A**: 不可以，系统会拒绝负数输入。

### Q5: 自动刷新会影响性能吗？

**A**: 不会，系统使用了优化的查询和缓存机制：
- 只在主页运行时刷新
- 离开页面自动停止
- 使用轻量级计数查询

---

## 🎉 总结

### **对于普通用户**:
- ✅ 主页统计数据自动更新
- ✅ 无需任何操作
- ✅ 数据始终保持最新

### **对于管理员**:
- ✅ 可以查看实时统计
- ✅ 可以手动修正数据（应急）
- ✅ 可以一键恢复自动模式
- ✅ 所有操作有记录和备注

### **系统优势**:
- 🔄 自动化 + 灵活性
- 🔐 安全的权限控制
- 📊 透明的数据来源
- 💾 完整的操作记录

---

**开发日期**: 2025-10-12  
**开发者**: AI Assistant  
**版本**: 1.0

🎊 **现在你的球房统计系统既智能又灵活！**

