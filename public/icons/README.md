# PWA Icons - 图标生成说明

## 📱 需要的图标尺寸

为了支持完整的PWA功能（iPhone和Android），需要生成以下尺寸的图标：

### iOS (Apple Touch Icons)
- `apple-touch-icon.png` - **180x180** (必需，iPhone主屏幕图标)
- `icon-152x152.png` - 152x152 (iPad)
- `icon-144x144.png` - 144x144
- `icon-128x128.png` - 128x128
- `icon-96x96.png` - 96x96
- `icon-72x72.png` - 72x72

### Android (Standard Icons)
- `icon-512x512.png` - **512x512** (必需，Android主屏幕图标)
- `icon-384x384.png` - 384x384
- `icon-192x192.png` - **192x192** (必需，Android主屏幕图标)
- `icon-32x32.png` - 32x32 (浏览器标签页)
- `icon-16x16.png` - 16x16 (浏览器标签页)

## 🎨 图标要求

1. **背景**：建议使用透明背景或与主题色匹配的背景
2. **内容**：使用Joy Billiards的Logo或品牌标识
3. **格式**：PNG格式，支持透明背景
4. **圆角**：iOS会自动添加圆角，所以图标本身不需要圆角
5. **安全区域**：重要内容应放在图标中心区域（避免被系统裁剪）

## 🛠️ 生成方法

### 方法1：使用在线工具
1. 访问 https://realfavicongenerator.net/ 或 https://www.pwabuilder.com/imageGenerator
2. 上传你的Logo文件（建议至少512x512px）
3. 选择"iOS"和"Android"平台
4. 下载生成的图标包
5. 将所有图标文件放到 `public/icons/` 目录

### 方法2：使用设计软件（Photoshop/Figma）
1. 创建512x512px的画布
2. 放置Logo（居中，留出10%的安全边距）
3. 导出为PNG格式
4. 使用工具批量生成其他尺寸：
   - 使用ImageMagick: `convert icon-512x512.png -resize 192x192 icon-192x192.png`
   - 或使用在线工具批量调整尺寸

### 方法3：使用命令行工具（ImageMagick）
```bash
# 安装ImageMagick (macOS)
brew install imagemagick

# 生成所有尺寸
convert logo.png -resize 512x512 public/icons/icon-512x512.png
convert logo.png -resize 384x384 public/icons/icon-384x384.png
convert logo.png -resize 192x192 public/icons/icon-192x192.png
convert logo.png -resize 180x180 public/icons/apple-touch-icon.png
convert logo.png -resize 152x152 public/icons/icon-152x152.png
convert logo.png -resize 144x144 public/icons/icon-144x144.png
convert logo.png -resize 128x128 public/icons/icon-128x128.png
convert logo.png -resize 96x96 public/icons/icon-96x96.png
convert logo.png -resize 72x72 public/icons/icon-72x72.png
convert logo.png -resize 32x32 public/icons/icon-32x32.png
convert logo.png -resize 16x16 public/icons/icon-16x16.png
```

## ✅ 验证清单

生成图标后，请确保：

- [ ] 所有图标文件都在 `public/icons/` 目录
- [ ] 文件名完全匹配（区分大小写）
- [ ] 图标清晰，没有模糊
- [ ] 重要内容在中心区域
- [ ] 测试iPhone Safari "添加到主屏幕"
- [ ] 测试Android Chrome "添加到主屏幕"

## 📝 当前状态

⚠️ **需要生成图标文件** - 请按照上述方法生成所有图标并放到 `public/icons/` 目录。

一旦图标文件就位，PWA功能将完全启用：
- ✅ iPhone Safari "添加到主屏幕"会显示自定义图标
- ✅ Android Chrome "添加到主屏幕"会显示自定义图标
- ✅ 打开时以App模式运行（无地址栏）
- ✅ 离线缓存功能
- ✅ 快速加载

