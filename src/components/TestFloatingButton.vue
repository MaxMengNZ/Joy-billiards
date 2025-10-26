<template>
  <div class="test-floating-button" :class="{ expanded: isExpanded }">
    <button @click="toggleExpanded" class="test-button">
      📱 {{ isExpanded ? 'Close' : 'Open' }}
    </button>
    
    <div class="test-social-buttons">
      <a href="https://www.facebook.com/profile.php?id=61578291092113" target="_blank" class="test-social-btn facebook">📘 FB</a>
      <a href="https://www.instagram.com/joybilliardsnz" target="_blank" class="test-social-btn instagram">📷 IG</a>
      <router-link to="/wechat" class="test-social-btn wechat">💬 WX</router-link>
      <a href="https://xhslink.com/m/2CwhEpZgtub" target="_blank" class="test-social-btn xiaohongshu">📝 XHS</a>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'TestFloatingButton',
  setup() {
    const isExpanded = ref(false)
    
    const toggleExpanded = () => {
      console.log('Test button clicked!', isExpanded.value)
      isExpanded.value = !isExpanded.value
      console.log('New state:', isExpanded.value)
    }
    
    return {
      isExpanded,
      toggleExpanded
    }
  }
}
</script>

<style scoped>
.test-floating-button {
  position: fixed;
  bottom: 80px; /* 提高位置，避免挡住底部导航 */
  right: 20px;
  z-index: 1000;
}

.test-button {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 12px;
  cursor: pointer;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
  transition: all 0.3s ease;
}

.test-button:hover {
  transform: scale(1.1);
}

.test-social-buttons {
  position: absolute;
  bottom: 70px;
  right: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.test-social-btn {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: white;
  font-size: 10px;
  font-weight: bold;
  transition: all 0.3s ease;
  opacity: 0;
  transform: translateY(20px) scale(0.8);
}

/* 展开状态 - 垂直布局 */
.test-floating-button.expanded .test-social-btn {
  opacity: 1;
  transform: translateY(0) scale(1);
}

/* 为每个按钮添加延迟动画 */
.test-floating-button.expanded .test-social-btn:nth-child(1) {
  transition-delay: 0.1s;
}

.test-floating-button.expanded .test-social-btn:nth-child(2) {
  transition-delay: 0.2s;
}

.test-floating-button.expanded .test-social-btn:nth-child(3) {
  transition-delay: 0.3s;
}

.test-floating-button.expanded .test-social-btn:nth-child(4) {
  transition-delay: 0.4s;
}

.test-social-btn.facebook {
  background: #1877f2;
}

.test-social-btn.instagram {
  background: linear-gradient(45deg, #f09433 0%, #e6683c 25%, #dc2743 50%, #cc2366 75%, #bc1888 100%);
}

.test-social-btn.wechat {
  background: #07c160;
}

.test-social-btn.xiaohongshu {
  background: #ff2442;
}

.test-social-btn:hover {
  transform: scale(1.1);
}

/* 移动端优化 - 确保不挡住底部导航 */
@media (max-width: 768px) {
  .test-floating-button {
    bottom: 100px; /* 进一步调整位置，确保不挡住底部导航 */
  }
  
  .test-social-buttons {
    bottom: 90px;
  }
}

/* 桌面端隐藏 */
@media (min-width: 769px) {
  .test-floating-button {
    display: none;
  }
}
</style>
