# 🎱 Battle Tier Boundary Rules - Critical Documentation

## ⚠️ 边界规则：左闭右开 [elo_min, elo_max)

### 核心规则

**所有段位函数必须使用左闭右开区间 `[elo_min, elo_max)`**，确保：
- ✅ 无重叠：每个 Elo 值只属于一个段位
- ✅ 无间隙：段位之间完美衔接
- ✅ 一致性：所有函数使用相同的边界逻辑

### 边界示例

| Elo 值 | 段位归属 | 说明 |
|--------|---------|------|
| 1999 | `gold_i` (1900-2000) | ✅ 在 gold_i 范围内 |
| **2000** | **`platinum_iv` (2000-2100)** | ✅ **关键边界：属于 platinum_iv，不是 gold_i** |
| 2001 | `platinum_iv` (2000-2100) | ✅ 在 platinum_iv 范围内 |
| 1099 | `bronze_iii` (1000-1100) | ✅ 在 bronze_iii 范围内 |
| **1100** | **`bronze_ii` (1100-1200)** | ✅ **边界：属于 bronze_ii，不是 bronze_iii** |
| 1101 | `bronze_ii` (1100-1200) | ✅ 在 bronze_ii 范围内 |

### 函数实现

#### 1. `get_battle_tier_from_elo(elo_rating INTEGER)`

```sql
WHERE elo_rating >= elo_min AND elo_rating < elo_max
```

**关键点**：
- `>= elo_min`：左闭（包含最小值）
- `< elo_max`：右开（不包含最大值）

**示例**：
- `elo=2000` → `platinum_iv`（因为 `2000 >= 2000 AND 2000 < 2100`）
- `elo=1999` → `gold_i`（因为 `1999 >= 1900 AND 1999 < 2000`）

#### 2. `calculate_battle_stars(p_elo INTEGER, p_tier TEXT)`

```sql
IF p_elo < v_min THEN
    RETURN 0;
ELSIF p_elo >= v_max THEN
    RETURN 3;  -- Ready to upgrade
END IF;
```

**关键点**：
- 如果 `p_elo >= v_max`，返回 3 星（准备升级）
- 否则在段位内计算星数（0-2 星）

### 验证测试

所有关键边界已通过测试：

| 边界点 | Elo | 归属段位 | 验证 |
|--------|-----|---------|------|
| Bronze III → II | 1100 | `bronze_ii` | ✅ |
| Gold I → Platinum IV | **2000** | **`platinum_iv`** | ✅ **关键** |
| Platinum I → Diamond V | 2400 | `diamond_v` | ✅ |

### 为什么使用左闭右开？

1. **避免重叠**：如果使用 `<= elo_max`，`elo=2000` 可能同时匹配 `gold_i` 和 `platinum_iv`
2. **完美衔接**：`gold_i` 结束于 2000，`platinum_iv` 开始于 2000，无缝连接
3. **数学标准**：左闭右开是区间划分的标准做法

### 数据库验证

系统自动验证：
- ✅ 无段位重叠
- ✅ 无段位间隙
- ✅ 所有函数使用一致的边界规则

### 注意事项

⚠️ **任何修改段位范围的代码都必须遵循此规则**：
- 段位配置：`elo_min` 和 `elo_max` 必须完美衔接
- 函数实现：必须使用 `>= elo_min AND < elo_max`
- 测试验证：必须测试所有边界点

---

**最后更新**：2026-01-09  
**状态**：✅ 已验证，无重叠，无间隙
