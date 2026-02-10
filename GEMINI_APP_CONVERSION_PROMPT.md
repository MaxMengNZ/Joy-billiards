# 提供给 Gemini AI 的「网站转 APP」提示词

将下面整段（或你修改后的版本）复制粘贴给 Gemini，用于把 Joy Billiards 网站设计成 APP。

---

## 提示词正文（复制从这里开始）

```
请帮我把现有的 Joy Billiards 网站改造成可安装的移动端 APP，要求保留现有全部功能和 Supabase 后端对接方式。

【项目概况】
- 名称：Joy Billiards Tournament System（新西兰 Joy Billiards 台球俱乐部）
- 当前形态：Vue 3 + Vite 单页应用，已部署为网站，使用 Supabase 作为后端
- 目标：生成可上架/分发的移动端 APP（iOS / Android 或 PWA 可安装应用），不更换后端，继续使用现有 Supabase 项目

【技术栈（必须保留/兼容）】
- 前端：Vue 3（Composition API）、Vue Router 4、Pinia
- 后端：Supabase（PostgreSQL + Auth + Realtime + Storage）
- 环境变量：VITE_SUPABASE_URL、VITE_SUPABASE_ANON_KEY（需在 APP 构建时注入或通过配置读取）
- 时区：所有时间显示和「今天」逻辑使用新西兰时区 Pacific/Auckland
- 语言：界面以英文为主，部分文案含中文（如「对战」「排行榜」）

【核心功能模块（需在 APP 中完整保留）】
1. 认证：注册、登录、邮箱验证、登出；角色：普通用户 / 管理员（admin）
2. 首页：活动/公告入口、导航到各模块
3. 个人资料（/profile）：头像、姓名、会员等级、Battle 段位与 Elo、连胜、Battle Tokens
4. Battle 对战系统（/battle）：
   - 创建房间（必填：房间名、Race To 局数、桌号 3–12、开球方式等）
   - 房间列表：等待中 / 准备中 / 进行中 / 今日已完成（按新西兰「今天」筛选）
   - 加入房间、确认准备、开始比赛、填写并提交比赛结果（胜者、双方比分、Break & Run 等）
   - 仅房主/参与者/管理员可完成比赛；提交时需已登录（移动端需处理 session 恢复与「请重新登录」提示）
5. Battle 排行榜（/battle/leaderboard）：段位榜、Elo、胜负数、连胜、Tier 图标；支持搜索与筛选；Realtime 更新
6. 赛事日历（/tournaments）：赛事列表、报名、管理员创建/编辑赛事与结果
7. Heyball 排行榜（/leaderboard）：月度/年度排名、导出
8. 会员与福利（/membership）、微信关注（/wechat）
9. 管理员：仪表盘（/admin）、玩家管理（/players）、注册监控（/monitoring）、未验证用户（/unverified-users）、TV 大屏（/tv-display）、Battle 快速开局（为任意两名玩家建房）

【API 与数据（不改变后端）】
- 所有数据通过 Supabase 客户端（@supabase/supabase-js）访问：Auth、Database、Realtime、Storage
- 主要表：users、battle_rooms、battle_match_scores、battle_tier_config、battle_match_history、tournaments/events 等
- RLS 已配置：按 auth 与 role 控制读写；APP 端继续使用 anon key + 登录后的 JWT

【移动端与体验要求】
- 响应式布局：在手机竖屏下导航清晰，主要操作（创建房间、加入、填写结果、查看排行榜）易于触达
- 登录态：APP 冷启动或从后台恢复时，若 Supabase session 仍存在（或可 refresh），应自动恢复登录，避免误报「Not authenticated」
- 错误提示：网络超时、未登录等需有明确文案，并引导用户「重新登录」或重试
- 时间：所有展示时间与「今日」逻辑统一为新西兰时间（Pacific/Auckland）

【产出要求】
请给出以下任一或组合方案（按你更擅长的来）：
1. 方案 A：在现有 Vue 3 项目上接入 Capacitor，生成 iOS/Android 原生壳 APP，保留现有 Vue 代码与 Supabase 配置，并说明如何配置环境变量与构建步骤。
2. 方案 B：将现有 Vue 3 应用改为 PWA（Service Worker、manifest、可安装到主屏幕），并说明如何确保在移动浏览器中可安装、离线/缓存策略可选。
3. 若你更熟悉 React Native / Flutter：请给出「用 React Native 或 Flutter 重写前端、继续调用同一 Supabase 后端」的架构与关键页面/接口对应关系，以及 Auth、Realtime、Storage 的接入要点。

最后，请列出：为完成你选择的方案，需要从我当前仓库中获取或你假设存在的文件/配置清单（例如 vite.config、router、stores、env 示例），以便我按清单提供给你或你按清单生成代码。
```

---

## 提示词正文（复制到这里结束）

---

## 使用建议

1. **一次性粘贴**：把上面「复制从这里开始」到「复制到这里结束」之间的整段提示词复制到 Gemini 对话里发送。
2. **按需微调**：若你更倾向某一种方案（只做 PWA / 只做 Capacitor / 只做 Flutter），可在提示词里把「请给出以下任一或组合方案」改成「请只给出方案 B：PWA」等。
3. **补充材料**：若 Gemini 要求具体文件内容，可从本仓库提供：
   - `package.json`
   - `src/router/index.js`
   - `src/stores/battleStore.js`（或 authStore.js）的片段
   - `src/config/supabase.js`
   - `vite.config.js`
   - `.env.example`（若存在，不要包含真实 key）
4. **环境变量**：APP 构建时仍需 `VITE_SUPABASE_URL` 和 `VITE_SUPABASE_ANON_KEY`，与现有网站一致即可。

---

*本文件仅用于提供给 Gemini 的提示词，不参与项目构建。*
