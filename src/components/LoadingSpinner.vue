<template>
  <div class="loading-spinner-container" :class="{ fullscreen }">
    <div class="loading-spinner" :class="`spinner-${variant}`" :style="spinnerStyle">
      <!-- Billiard Ball Spinner -->
      <div v-if="variant === 'billiard'" class="billiard-spinner">
        <div class="ball ball-8">8</div>
        <div class="ball ball-cue"></div>
      </div>
      
      <!-- Dots Spinner -->
      <div v-else-if="variant === 'dots'" class="dots-spinner">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div>
      
      <!-- Circular Spinner -->
      <div v-else-if="variant === 'circular'" class="circular-spinner">
        <svg viewBox="0 0 50 50">
          <circle cx="25" cy="25" r="20" fill="none" stroke-width="4"></circle>
        </svg>
      </div>
      
      <!-- Pulse Spinner -->
      <div v-else-if="variant === 'pulse'" class="pulse-spinner">
        <div class="pulse-ring"></div>
        <div class="pulse-ring"></div>
        <div class="pulse-ring"></div>
      </div>
      
      <!-- Default Spinner -->
      <div v-else class="default-spinner"></div>
    </div>
    
    <p v-if="text" class="loading-text">{{ text }}</p>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'billiard',
    validator: (value) => ['billiard', 'dots', 'circular', 'pulse', 'default'].includes(value)
  },
  size: {
    type: [String, Number],
    default: 60
  },
  color: {
    type: String,
    default: '#667eea'
  },
  fullscreen: {
    type: Boolean,
    default: false
  },
  text: {
    type: String,
    default: ''
  }
})

const spinnerStyle = computed(() => ({
  '--spinner-size': typeof props.size === 'number' ? `${props.size}px` : props.size,
  '--spinner-color': props.color
}))
</script>

<style scoped>
.loading-spinner-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 2rem;
}

.loading-spinner-container.fullscreen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(8px);
  z-index: 9999;
}

.loading-spinner {
  width: var(--spinner-size, 60px);
  height: var(--spinner-size, 60px);
  position: relative;
}

/* Billiard Ball Spinner */
.billiard-spinner {
  width: 100%;
  height: 100%;
  position: relative;
  animation: rotate 2s linear infinite;
}

.ball {
  position: absolute;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  color: white;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.ball-8 {
  background: linear-gradient(135deg, #1a1a1a 0%, #000000 100%);
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  font-size: 1.5rem;
}

.ball-cue {
  background: linear-gradient(135deg, #f0f0f0 0%, #ffffff 100%);
  width: 30px;
  height: 30px;
  animation: orbit 1.5s linear infinite;
}

@keyframes rotate {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

@keyframes orbit {
  0% {
    top: 0;
    left: 50%;
    transform: translate(-50%, -50%);
  }
  25% {
    top: 50%;
    left: 100%;
    transform: translate(-50%, -50%);
  }
  50% {
    top: 100%;
    left: 50%;
    transform: translate(-50%, -50%);
  }
  75% {
    top: 50%;
    left: 0;
    transform: translate(-50%, -50%);
  }
  100% {
    top: 0;
    left: 50%;
    transform: translate(-50%, -50%);
  }
}

/* Dots Spinner */
.dots-spinner {
  display: flex;
  gap: 0.5rem;
  align-items: center;
  justify-content: center;
}

.dot {
  width: 12px;
  height: 12px;
  background: var(--spinner-color, #667eea);
  border-radius: 50%;
  animation: dot-bounce 1.4s ease-in-out infinite both;
}

.dot:nth-child(1) {
  animation-delay: -0.32s;
}

.dot:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes dot-bounce {
  0%, 80%, 100% {
    transform: scale(0);
    opacity: 0.5;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

/* Circular Spinner */
.circular-spinner {
  width: 100%;
  height: 100%;
  animation: rotate 2s linear infinite;
}

.circular-spinner svg {
  width: 100%;
  height: 100%;
}

.circular-spinner circle {
  stroke: var(--spinner-color, #667eea);
  stroke-linecap: round;
  stroke-dasharray: 90, 150;
  stroke-dashoffset: 0;
  animation: circular-dash 1.5s ease-in-out infinite;
}

@keyframes circular-dash {
  0% {
    stroke-dasharray: 1, 150;
    stroke-dashoffset: 0;
  }
  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -35;
  }
  100% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -124;
  }
}

/* Pulse Spinner */
.pulse-spinner {
  width: 100%;
  height: 100%;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.pulse-ring {
  position: absolute;
  width: 100%;
  height: 100%;
  border: 4px solid var(--spinner-color, #667eea);
  border-radius: 50%;
  animation: pulse-ring 1.5s cubic-bezier(0.215, 0.61, 0.355, 1) infinite;
}

.pulse-ring:nth-child(2) {
  animation-delay: 0.5s;
}

.pulse-ring:nth-child(3) {
  animation-delay: 1s;
}

@keyframes pulse-ring {
  0% {
    transform: scale(0.33);
    opacity: 1;
  }
  80%, 100% {
    transform: scale(1);
    opacity: 0;
  }
}

/* Default Spinner */
.default-spinner {
  width: 100%;
  height: 100%;
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-top-color: var(--spinner-color, #667eea);
  border-radius: 50%;
  animation: rotate 0.8s linear infinite;
}

/* Loading Text */
.loading-text {
  color: #6b7280;
  font-size: 1rem;
  font-weight: 500;
  margin: 0;
  animation: fade-pulse 1.5s ease-in-out infinite;
}

@keyframes fade-pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}
</style>


