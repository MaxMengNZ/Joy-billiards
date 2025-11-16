<template>
  <div class="floating-social-container">
    <!-- 背景遮罩层 -->
    <div 
      v-if="isExpanded" 
      class="floating-backdrop" 
      @click="toggleExpanded"
    ></div>
    
    <!-- 社交媒体按钮组 -->
    <div class="social-buttons-group" :class="{ expanded: isExpanded }">
      <!-- Facebook -->
      <a 
        href="https://www.facebook.com/profile.php?id=61578291092113" 
        target="_blank" 
        rel="noopener noreferrer" 
        class="social-button facebook"
        title="Follow us on Facebook"
      >
        <span class="social-icon">📘</span>
        <span class="social-label">Facebook</span>
      </a>
      
      <!-- Instagram -->
      <a 
        href="https://www.instagram.com/joybilliardsnz" 
        target="_blank" 
        rel="noopener noreferrer" 
        class="social-button instagram"
        title="Follow us on Instagram"
      >
        <span class="social-icon">📷</span>
        <span class="social-label">Instagram</span>
      </a>
      
      <!-- WeChat -->
      <router-link 
        to="/wechat" 
        class="social-button wechat"
        title="Follow us on WeChat"
      >
        <span class="social-icon">💬</span>
        <span class="social-label">WeChat</span>
      </router-link>
      
      <!-- 小红书 -->
      <a 
        href="https://xhslink.com/m/2CwhEpZgtub" 
        target="_blank" 
        rel="noopener noreferrer" 
        class="social-button xiaohongshu"
        title="Follow us on 小红书"
      >
        <span class="social-icon">📝</span>
        <span class="social-label">小红书</span>
      </a>
    </div>
    
    <!-- 主按钮 -->
    <button 
      class="main-floating-button" 
      @click="toggleExpanded"
      :class="{ expanded: isExpanded }"
    >
      <span class="button-icon" :class="{ rotated: isExpanded }">📱</span>
    </button>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'FloatingSocialButton',
  setup() {
    const isExpanded = ref(false) // 默认收起，必须点击才能展开
    
    const toggleExpanded = () => {
      console.log('FloatingSocialButton clicked!', isExpanded.value)
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
.floating-social-container {
  position: fixed;
  bottom: 20px;
  right: 20px;
  z-index: 1000;
  pointer-events: none;
}

.floating-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  backdrop-filter: blur(2px);
  z-index: 999;
  pointer-events: auto;
}

.main-floating-button {
  position: relative;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  border: none;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-size: 24px;
  cursor: pointer;
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
  transition: all 0.3s ease;
  pointer-events: auto;
  z-index: 1001;
  display: flex;
  align-items: center;
  justify-content: center;
}

.main-floating-button:hover {
  transform: scale(1.1);
  box-shadow: 0 12px 35px rgba(102, 126, 234, 0.6);
}

.main-floating-button.expanded {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  box-shadow: 0 8px 25px rgba(245, 87, 108, 0.4);
}

.button-icon {
  transition: transform 0.3s ease;
}

.button-icon.rotated {
  transform: rotate(45deg);
}

.social-buttons-group {
  position: absolute;
  bottom: 0;
  right: 0;
  pointer-events: none;
}

.social-buttons-group.expanded {
  pointer-events: auto;
}

.social-button {
  position: absolute;
  bottom: 0;
  right: 0;
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: white;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  opacity: 0;
  transform: scale(0);
  pointer-events: none;
  visibility: hidden; /* 完全隐藏，阻止点击 */
}

.social-buttons-group.expanded .social-button {
  opacity: 1;
  transform: scale(1);
  pointer-events: auto;
  visibility: visible; /* 展开时才可见可点击 */
}

.social-button:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.social-icon {
  font-size: 20px;
}

.social-button.facebook {
  background: linear-gradient(135deg, #1877f2 0%, #42a5f5 100%);
}

.social-button.instagram {
  background: linear-gradient(135deg, #e4405f 0%, #fd1d1d 50%, #fcb045 100%);
}

.social-button.wechat {
  background: linear-gradient(135deg, #07c160 0%, #38d9a9 100%);
}

.social-button.xiaohongshu {
  background: linear-gradient(135deg, #ff2442 0%, #ff6b6b 100%);
}

.social-label {
  position: absolute;
  right: 60px;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(0, 0, 0, 0.8);
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  white-space: nowrap;
  opacity: 0;
  transition: opacity 0.3s ease;
  pointer-events: none;
}

.social-button:hover .social-label {
  opacity: 1;
}

/* 扇形布局 */
.social-buttons-group.expanded .social-button:nth-child(1) {
  transform: translate(-70px, -20px) scale(1);
}

.social-buttons-group.expanded .social-button:nth-child(2) {
  transform: translate(-50px, -50px) scale(1);
}

.social-buttons-group.expanded .social-button:nth-child(3) {
  transform: translate(-20px, -70px) scale(1);
}

.social-buttons-group.expanded .social-button:nth-child(4) {
  transform: translate(10px, -80px) scale(1);
}

/* 移动端优化 */
@media (max-width: 768px) {
  .floating-social-container {
    bottom: 15px;
    right: 15px;
  }
  
  .main-floating-button {
    width: 55px;
    height: 55px;
    font-size: 22px;
  }
  
  .social-button {
    width: 45px;
    height: 45px;
  }
  
  .social-label {
    font-size: 11px;
    padding: 4px 8px;
  }
}

/* 桌面端隐藏 */
@media (min-width: 769px) {
  .floating-social-container {
    display: none;
  }
}
</style>
