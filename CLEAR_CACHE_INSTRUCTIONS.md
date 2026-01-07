# 🚨 紧急修复：网站无法打开

## 问题原因
Service Worker 缓存了错误的代码，导致网站无法加载。

## 立即修复步骤

### 方法 1：清除浏览器缓存（推荐）

**Chrome/Edge:**
1. 按 `F12` 打开开发者工具
2. 转到 `Application` 标签
3. 点击左侧 `Service Workers`
4. 点击 `Unregister` 卸载所有 Service Worker
5. 点击左侧 `Cache Storage`
6. 右键点击每个缓存，选择 `Delete`
7. 刷新页面（`Cmd+Shift+R` 或 `Ctrl+Shift+R`）

**Safari:**
1. 按 `Cmd+Option+E` 清除缓存
2. 刷新页面

**Firefox:**
1. 按 `Cmd+Shift+Delete`（Mac）或 `Ctrl+Shift+Delete`（Windows）
2. 选择 "缓存"，点击 "清除"
3. 刷新页面

### 方法 2：使用无痕模式
- 打开无痕/隐私浏览窗口
- 访问网站（无痕模式不使用 Service Worker 缓存）

### 方法 3：在浏览器控制台运行（最快）

打开浏览器控制台（F12），运行：

```javascript
// 清除所有 Service Worker
navigator.serviceWorker.getRegistrations().then(registrations => {
  registrations.forEach(registration => registration.unregister())
  console.log('✅ Service Workers cleared')
})

// 清除所有缓存
caches.keys().then(keys => {
  keys.forEach(key => caches.delete(key))
  console.log('✅ Caches cleared')
})

// 强制刷新
location.reload(true)
```

## 已应用的修复

1. ✅ 临时禁用了 Service Worker 注册
2. ✅ 添加了自动清除 Service Worker 的逻辑
3. ✅ 更新了 Service Worker 不缓存 JS/HTML 文件

## 验证修复

清除缓存后，网站应该能正常加载。如果还有问题，请：
1. 检查浏览器控制台是否有错误
2. 尝试硬刷新（Cmd+Shift+R）
3. 尝试无痕模式

