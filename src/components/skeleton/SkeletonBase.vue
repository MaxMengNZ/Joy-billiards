<template>
  <div 
    class="skeleton-base" 
    :class="[
      `skeleton-${variant}`,
      { 'skeleton-rounded': rounded },
      { 'skeleton-circle': circle },
      customClass
    ]"
    :style="computedStyle"
  ></div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  width: {
    type: [String, Number],
    default: '100%'
  },
  height: {
    type: [String, Number],
    default: '20px'
  },
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'text', 'rectangular', 'circular'].includes(value)
  },
  rounded: {
    type: Boolean,
    default: false
  },
  circle: {
    type: Boolean,
    default: false
  },
  customClass: {
    type: String,
    default: ''
  }
})

const computedStyle = computed(() => ({
  width: typeof props.width === 'number' ? `${props.width}px` : props.width,
  height: typeof props.height === 'number' ? `${props.height}px` : props.height
}))
</script>

<style scoped>
.skeleton-base {
  background: linear-gradient(
    90deg,
    #f0f0f0 0%,
    #f8f8f8 50%,
    #f0f0f0 100%
  );
  background-size: 200% 100%;
  animation: skeleton-loading 1.5s ease-in-out infinite;
  border-radius: 4px;
}

@keyframes skeleton-loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

.skeleton-text {
  height: 16px;
  margin-bottom: 8px;
}

.skeleton-text:last-child {
  width: 80%;
}

.skeleton-rectangular {
  border-radius: 8px;
}

.skeleton-circular {
  border-radius: 50%;
}

.skeleton-rounded {
  border-radius: 12px;
}

.skeleton-circle {
  border-radius: 50%;
  width: var(--skeleton-size, 40px);
  height: var(--skeleton-size, 40px);
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  .skeleton-base {
    background: linear-gradient(
      90deg,
      #2a2a2a 0%,
      #3a3a3a 50%,
      #2a2a2a 100%
    );
  }
}
</style>


