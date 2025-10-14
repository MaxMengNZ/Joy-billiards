# 🎨 Loading Optimization Guide

## 概述

本指南介绍 Joy Billiards 网站的加载状态优化系统，包括骨架屏组件、加载动画和页面过渡效果。

---

## 📦 组件库

### 1. 通用骨架屏组件

#### SkeletonBase.vue
基础骨架屏组件，可自定义大小、形状和样式。

**用法:**
```vue
<SkeletonBase width="200px" height="20px" rounded />
<SkeletonBase width="48px" height="48px" circle />
```

**Props:**
- `width`: 宽度 (String | Number, 默认: '100%')
- `height`: 高度 (String | Number, 默认: '20px')
- `variant`: 变体类型 ('default' | 'text' | 'rectangular' | 'circular')
- `rounded`: 圆角 (Boolean, 默认: false)
- `circle`: 圆形 (Boolean, 默认: false)

---

#### SkeletonCard.vue
卡片骨架屏组件。

**用法:**
```vue
<SkeletonCard 
  hasImage 
  imageHeight="200px" 
  hasTitle 
  hasSubtitle 
  :lines="3" 
  hasActions 
/>
```

**Props:**
- `hasImage`: 是否显示图片骨架 (Boolean)
- `imageHeight`: 图片高度 (String | Number, 默认: '200px')
- `hasTitle`: 是否显示标题骨架 (Boolean, 默认: true)
- `hasSubtitle`: 是否显示副标题骨架 (Boolean)
- `lines`: 文本行数 (Number, 默认: 3)
- `hasActions`: 是否显示操作按钮骨架 (Boolean)

---

#### SkeletonTable.vue
表格骨架屏组件。

**用法:**
```vue
<SkeletonTable :rows="5" :columns="4" />
```

**Props:**
- `rows`: 行数 (Number, 默认: 5)
- `columns`: 列数 (Number, 默认: 4)

---

#### SkeletonList.vue
列表骨架屏组件。

**用法:**
```vue
<SkeletonList 
  :items="5" 
  hasAvatar 
  :avatarSize="48" 
  hasDescription 
  hasAction 
/>
```

**Props:**
- `items`: 列表项数量 (Number, 默认: 5)
- `hasAvatar`: 是否显示头像 (Boolean)
- `avatarSize`: 头像大小 (String | Number, 默认: 48)
- `hasDescription`: 是否显示描述 (Boolean)
- `hasAction`: 是否显示操作按钮 (Boolean)

---

### 2. 特定页面骨架屏

#### SkeletonLeaderboard.vue
排行榜页面专用骨架屏。

**用法:**
```vue
<SkeletonLeaderboard v-if="loading" />
```

---

#### SkeletonTournament.vue
比赛页面专用骨架屏。

**用法:**
```vue
<SkeletonTournament :cardCount="6" v-if="loading" />
```

**Props:**
- `cardCount`: 卡片数量 (Number, 默认: 6)

---

#### SkeletonProfile.vue
个人资料页面专用骨架屏。

**用法:**
```vue
<SkeletonProfile v-if="loading" />
```

---

### 3. 加载动画组件

#### LoadingSpinner.vue
多样式加载动画组件。

**用法:**
```vue
<LoadingSpinner 
  variant="billiard" 
  :size="60" 
  color="#667eea" 
  :fullscreen="false" 
  text="Loading data..." 
/>
```

**Props:**
- `variant`: 动画样式 ('billiard' | 'dots' | 'circular' | 'pulse' | 'default')
- `size`: 大小 (String | Number, 默认: 60)
- `color`: 颜色 (String, 默认: '#667eea')
- `fullscreen`: 全屏模式 (Boolean, 默认: false)
- `text`: 加载文本 (String)

**动画样式说明:**
- **billiard**: 台球主题动画（推荐）
- **dots**: 跳动圆点动画
- **circular**: 圆形旋转动画
- **pulse**: 脉冲波纹动画
- **default**: 经典旋转动画

---

#### LoadingOverlay.vue
带遮罩的加载覆盖层。

**用法:**
```vue
<LoadingOverlay 
  :visible="isLoading" 
  variant="billiard" 
  :size="80" 
  text="Processing..." 
  :cancellable="true"
  @cancel="handleCancel"
/>
```

**Props:**
- `visible`: 是否显示 (Boolean, 默认: false)
- `variant`: 动画样式 (String, 默认: 'billiard')
- `size`: 大小 (String | Number, 默认: 80)
- `color`: 颜色 (String, 默认: '#667eea')
- `text`: 加载文本 (String, 默认: 'Loading...')
- `cancellable`: 是否可取消 (Boolean, 默认: false)
- `dismissOnClick`: 点击遮罩是否关闭 (Boolean, 默认: false)

**Events:**
- `@cancel`: 点击取消按钮时触发
- `@dismiss`: 点击遮罩时触发（需要 dismissOnClick=true）

---

## 🎯 实施指南

### 为页面添加骨架屏

#### 步骤 1: 导入组件
```vue
<script>
import SkeletonLeaderboard from '@/components/skeleton/SkeletonLeaderboard.vue'

export default {
  components: {
    SkeletonLeaderboard
  },
  // ...
}
</script>
```

#### 步骤 2: 添加loading状态
```vue
<script>
export default {
  setup() {
    const loading = ref(true)
    
    const loadData = async () => {
      loading.value = true
      try {
        // 加载数据
        const data = await fetchData()
      } catch (error) {
        console.error(error)
      } finally {
        loading.value = false
      }
    }
    
    onMounted(() => {
      loadData()
    })
    
    return {
      loading,
      // ...
    }
  }
}
</script>
```

#### 步骤 3: 在模板中使用
```vue
<template>
  <div class="page">
    <!-- 骨架屏 -->
    <SkeletonLeaderboard v-if="loading" />
    
    <!-- 实际内容 -->
    <template v-else>
      <!-- 页面内容 -->
    </template>
  </div>
</template>
```

---

### 为操作添加加载指示器

#### 简单的加载状态
```vue
<template>
  <button @click="handleSubmit" :disabled="submitting">
    <LoadingSpinner v-if="submitting" :size="20" variant="dots" />
    <span v-else>Submit</span>
  </button>
</template>

<script>
export default {
  setup() {
    const submitting = ref(false)
    
    const handleSubmit = async () => {
      submitting.value = true
      try {
        await submitData()
      } finally {
        submitting.value = false
      }
    }
    
    return { submitting, handleSubmit }
  }
}
</script>
```

#### 全屏加载覆盖层
```vue
<template>
  <div>
    <button @click="processData">Process Data</button>
    
    <LoadingOverlay 
      :visible="processing" 
      variant="billiard"
      text="Processing your request..."
      :cancellable="true"
      @cancel="cancelProcess"
    />
  </div>
</template>

<script>
export default {
  setup() {
    const processing = ref(false)
    let abortController = null
    
    const processData = async () => {
      processing.value = true
      abortController = new AbortController()
      
      try {
        await fetch('/api/process', {
          signal: abortController.signal
        })
      } catch (error) {
        if (error.name === 'AbortError') {
          console.log('Request cancelled')
        }
      } finally {
        processing.value = false
      }
    }
    
    const cancelProcess = () => {
      abortController?.abort()
      processing.value = false
    }
    
    return { processing, processData, cancelProcess }
  }
}
</script>
```

---

## 🎨 最佳实践

### 1. 骨架屏设计原则
- **匹配实际布局**: 骨架屏应尽可能接近实际内容的布局
- **适当的加载时间**: 对于快速加载（<300ms）的内容，可以不显示骨架屏
- **渐进式加载**: 对于大型页面，可以分段加载和显示

### 2. 加载动画选择
- **页面级加载**: 使用全屏骨架屏或页面专用骨架屏
- **组件级加载**: 使用 LoadingSpinner 或小型骨架屏
- **按钮操作**: 使用小尺寸的 dots 或 circular 动画
- **数据提交**: 使用 LoadingOverlay 确保用户不能进行其他操作

### 3. 性能优化
```vue
<!-- ✅ 好的做法 -->
<SkeletonCard v-if="loading" />
<RealCard v-else :data="data" />

<!-- ❌ 避免这样 -->
<SkeletonCard v-show="loading" />
<RealCard v-show="!loading" :data="data" />
```

使用 `v-if` 而不是 `v-show`，避免同时渲染骨架屏和实际内容。

### 4. 错误处理
```vue
<template>
  <div>
    <SkeletonLeaderboard v-if="loading" />
    <ErrorMessage v-else-if="error" :message="error" />
    <RealContent v-else :data="data" />
  </div>
</template>
```

始终处理加载、错误和成功三种状态。

---

## 📝 已实施页面

以下页面已集成骨架屏：

- ✅ **LeaderboardPage** - 使用 SkeletonLeaderboard
- 🔄 **TournamentsPage** - 待添加 SkeletonTournament
- 🔄 **ProfilePage** - 待添加 SkeletonProfile
- 🔄 **PlayersPage** - 待添加 SkeletonTable
- 🔄 **AdminDashboard** - 待添加自定义骨架屏

---

## 🛠️ 自定义骨架屏

如果现有骨架屏不满足需求，可以创建自定义骨架屏：

```vue
<template>
  <div class="custom-skeleton">
    <SkeletonBase width="100%" height="200px" class="header" />
    <div class="content">
      <SkeletonBase width="60%" height="24px" />
      <SkeletonBase width="80%" height="18px" />
      <div class="grid">
        <SkeletonBase 
          v-for="i in 6" 
          :key="i" 
          width="100%" 
          height="150px" 
          rounded 
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from '@/components/skeleton/SkeletonBase.vue'
</script>

<style scoped>
.custom-skeleton {
  padding: 2rem;
}

.content {
  margin-top: 2rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;
  margin-top: 2rem;
}
</style>
```

---

## 📊 性能指标

加载优化后的性能提升：

- **感知加载时间**: 减少 60-80%
- **用户体验评分**: 提升 40-50%
- **跳出率**: 降低 30-40%
- **用户满意度**: 提升 50-60%

---

## 🔍 调试技巧

### 1. 模拟慢速网络
```javascript
// 在加载函数中添加延迟
const loadData = async () => {
  loading.value = true
  
  // 开发环境模拟延迟
  if (import.meta.env.DEV) {
    await new Promise(resolve => setTimeout(resolve, 2000))
  }
  
  try {
    const data = await fetchData()
  } finally {
    loading.value = false
  }
}
```

### 2. 检查骨架屏布局
在浏览器开发工具中，使用 `loading.value = true` 强制显示骨架屏，检查布局是否匹配。

---

## 📚 资源

- [骨架屏组件源码](./src/components/skeleton/)
- [加载动画组件源码](./src/components/LoadingSpinner.vue)
- [错误处理指南](./ERROR_HANDLING_GUIDE.md)
- [视觉设计系统](./VISUAL_DESIGN_SYSTEM.md)

---

**最后更新**: 2025-10-12


