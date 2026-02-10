# 在 Cursor 中连接 Stitch MCP

本项目已配置 **Google Stitch** 的 MCP 服务器，便于在 Cursor 里用 Stitch 的设计生成或修改代码（如 Joy Billiards 的 UI）。

---

## 1. 已完成的配置

在项目根目录下已创建 **`.cursor/mcp.json`**，内容为：

```json
{
  "mcpServers": {
    "stitch": {
      "url": "https://stitch.withgoogle.com/mcp"
    }
  }
}
```

这样在 Cursor 中打开本项目时，会加载 Stitch MCP 服务器。

---

## 2. 你需要做的：在 Cursor 里完成授权

1. **重启或重新加载 Cursor**  
   若刚添加配置，可关闭并重新打开本项目，或使用 Cursor 的 “Reload Window” 确保读取新的 `mcp.json`。

2. **查看 MCP 状态**  
   - 打开 **Cursor Settings**（`Cmd + ,`）  
   - 进入 **Features → MCP**（或 **Cursor Settings → MCP**）  
   - 找到 **stitch**，查看是否显示 “Needs authentication” 或类似提示。

3. **完成 Stitch 授权**  
   - 点击 **“Authenticate”** 或 **“Connect”**  
   - 在浏览器中登录你的 **Google 账号**，并同意 Stitch 访问  
   - 授权成功后，Stitch 会显示为已连接（例如 “21 tools enabled”）

4. **验证**  
   在对话里让 AI “列出可用的 MCP 工具” 或 “用 Stitch 读一下当前设计”，若能调用 Stitch 相关工具，即表示已连接成功。

---

## 3. 若你手上有 Stitch 的 API Key / Token

目前 Stitch 官方文档说明 MCP 使用 **OAuth2** 授权，**不支持仅用 API Key**。若你拿到的是：

- **OAuth 授权链接**：在 Cursor 里点 “Authenticate” 后，在浏览器中完成即可，无需改配置。  
- **API Key / Token**：若 Stitch 之后支持在 MCP 里用 API Key，可以在 `.cursor/mcp.json` 里改为通过 `mcp-remote` + header 的方式传入，例如：

```json
{
  "mcpServers": {
    "stitch": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://stitch.withgoogle.com/mcp",
        "--header",
        "Authorization: Bearer YOUR_STITCH_API_KEY"
      ]
    }
  }
}
```

（请将 `YOUR_STITCH_API_KEY` 替换为 Stitch 提供给你的 key；具体 header 名称以 Stitch 官方文档为准。）

若你提供 Stitch 给你的 **具体 API 文档或示例**（例如要求的 header 名称、是否用 Bearer token），可以再根据文档把上面配置改成最终可用版本。

---

## 4. 连接成功后可以做什么

- 在 **Stitch** 里用文字或草图生成 UI 设计。  
- 在 **Cursor** 里对 AI 说：“根据 Stitch 里 [某设计/某页面] 生成 Vue 组件” 或 “把 HomePage 按 Stitch 里这个设计改一版”。  
- AI 会通过 Stitch MCP 读取设计信息，并生成或修改本项目中的 Vue 3 代码。

---

## 5. 故障排查

- **看不到 Stitch 或显示未连接**  
  - 确认 `.cursor/mcp.json` 在项目根目录且格式正确。  
  - 重启 Cursor 或 Reload Window 后再看 MCP 列表。

- **一直提示需要认证**  
  - 在 Cursor 里点 Stitch 的 “Authenticate”，在浏览器中完成 Google 登录与授权。  
  - 若使用公司/学校 Google 账号，需确认该账号允许使用 Stitch。

- **Stitch 官方文档**  
  - MCP 指南：<https://stitch.withgoogle.com/docs/mcp/guide>

---

**下一步**：完成上述授权后，你可以直接说 “用 Stitch 读一下我当前的设计” 或 “按 Stitch 里某某设计改 HomePage”，我会基于 Stitch 的输出来改代码。
