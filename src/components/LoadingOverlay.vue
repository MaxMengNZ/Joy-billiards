<template>
  <transition name="fade">
    <div v-if="visible" class="loading-overlay" @click.self="handleOverlayClick">
      <div class="loading-content">
        <LoadingSpinner 
          :variant="variant" 
          :size="size" 
          :color="color" 
          :text="text"
        />
        <button 
          v-if="cancellable" 
          @click="cancel" 
          class="cancel-button"
        >
          Cancel
        </button>
      </div>
    </div>
  </transition>
</template>

<script setup>
import LoadingSpinner from './LoadingSpinner.vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  variant: {
    type: String,
    default: 'billiard'
  },
  size: {
    type: [String, Number],
    default: 80
  },
  color: {
    type: String,
    default: '#667eea'
  },
  text: {
    type: String,
    default: 'Loading...'
  },
  cancellable: {
    type: Boolean,
    default: false
  },
  dismissOnClick: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['cancel', 'dismiss'])

const handleOverlayClick = () => {
  if (props.dismissOnClick) {
    emit('dismiss')
  }
}

const cancel = () => {
  emit('cancel')
}
</script>

<style scoped>
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  cursor: pointer;
}

.loading-content {
  background: white;
  border-radius: 24px;
  padding: 3rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  cursor: default;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2rem;
  min-width: 300px;
}

.cancel-button {
  padding: 0.75rem 2rem;
  background: #ef4444;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.cancel-button:hover {
  background: #dc2626;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>


