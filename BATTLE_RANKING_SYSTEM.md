# 🎱 Battle Ranking System - Battle段位排行系统

## 概述

这是一个完全独立的Battle段位排行系统，与原有的周赛排行榜系统完全分离。系统基于Elo评分，使用段位/星数机制（类似手游排位系统）。

## 已完成的工作

### 1. 数据库结构

#### 新增字段（users表）
- `battle_elo_rating` (INTEGER): 统一的Battle Elo评分（默认1000）
- `battle_tier` (VARCHAR): 当前段位（如 'bronze_iii', 'gold_i'）
- `battle_stars` (INTEGER): 当前段位内的星数（0-3）
- `battle_wins` (INTEGER): 总胜场数
- `battle_losses` (INTEGER): 总负场数
- `battle_position` (INTEGER): 全球排名
- `battle_streak` (INTEGER): 连胜/连败数
- `last_battle_match_at` (TIMESTAMP): 最后比赛时间

#### 段位配置表（battle_tier_config）
定义了所有段位的信息：
- 段位名称（中英文）
- Elo范围（elo_min, elo_max）
- 星数要求（stars_required）
- 低段位保护（star_protection）
- 积分系数（point_coefficient）
- 全国档位（national_tier）
- 段位继承（rank_inheritance）

### 2. 段位系统（28个段位）

#### 三颗星组（1-6）
- 沉稳青铜 III/I/II
- 推杆白银 III/I/II

#### 四颗星组（7-14）
- 走位黄金 IV/III/II/I
- 加塞铂金 IV/III/II/I

#### 五颗星组（15-24）
- 校球钻石 V/IV/III/II/I
- 清台星耀 V/IV/III/II/I

#### 杆王组（25-28）
- 最强杆王（0-25颗星）
- 无双杆王（26-49颗星）
- 荣耀杆王（50-99颗星）
- 传奇杆王（100+颗星）

### 3. 核心函数

- `get_battle_tier_from_elo(elo_rating)`: 根据Elo获取段位
- `calculate_battle_stars(elo_rating, tier_name)`: 计算星数
- `update_battle_tier_and_stars()`: 自动更新段位和星数（触发器）
- `update_battle_positions()`: 更新全球排名
- `get_tier_difference(tier1, tier2)`: 计算段位差（用于挑战赛）

### 4. 前端更新

- 更新了 `BattleProfileModal.vue` 显示新的段位系统
- 显示段位名称、星数、Elo评分、排名
- 显示统一的Battle统计数据（不再区分Pro/Student）

## 待完成的工作

### 1. 更新Elo计算逻辑

需要修改 `battle_rooms_system.sql` 中的触发器，使用统一的 `battle_elo_rating` 而不是 `elo_rating_pro` 和 `elo_rating_student`。

### 2. 实现匹配赛和挑战赛规则

根据图片中的逻辑：
- **匹配赛（Matchmaking）**: 对手在上下一个大段位内，胜利+1星，失败-1星
- **挑战赛（Challenge Match）**: 对手超匹配区间
  - 低段位败高段位：+段位差星
  - 高段位败低段位：-段位差星

### 3. 低段位保护机制

- 黄金IV以下：失败不降星
- 黄金III开始：失败扣1星

### 4. 初始化现有用户

需要将现有用户的Elo评分迁移到统一的 `battle_elo_rating` 字段。

## 下一步

1. 更新Battle房间完成时的Elo计算逻辑
2. 实现匹配赛/挑战赛的星数计算
3. 创建Battle排行榜页面
4. 添加段位图标和视觉效果
