<template>
  <div class="skeleton-card">
    <SkeletonBase v-if="hasImage" :height="imageHeight" class="skeleton-card-image" />
    <div class="skeleton-card-content">
      <SkeletonBase v-if="hasTitle" width="70%" height="24px" class="skeleton-card-title" />
      <SkeletonBase v-if="hasSubtitle" width="50%" height="18px" class="skeleton-card-subtitle" />
      <div v-if="lines > 0" class="skeleton-card-lines">
        <SkeletonBase 
          v-for="i in lines" 
          :key="i" 
          :width="i === lines ? '80%' : '100%'" 
          height="16px" 
          class="skeleton-line"
        />
      </div>
      <div v-if="hasActions" class="skeleton-card-actions">
        <SkeletonBase width="80px" height="36px" rounded />
        <SkeletonBase width="80px" height="36px" rounded />
      </div>
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'

defineProps({
  hasImage: {
    type: Boolean,
    default: false
  },
  imageHeight: {
    type: [String, Number],
    default: '200px'
  },
  hasTitle: {
    type: Boolean,
    default: true
  },
  hasSubtitle: {
    type: Boolean,
    default: false
  },
  lines: {
    type: Number,
    default: 3
  },
  hasActions: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.skeleton-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.skeleton-card-image {
  border-radius: 0;
}

.skeleton-card-content {
  padding: 1.5rem;
}

.skeleton-card-title {
  margin-bottom: 1rem;
}

.skeleton-card-subtitle {
  margin-bottom: 1rem;
}

.skeleton-card-lines {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.skeleton-card-actions {
  display: flex;
  gap: 1rem;
}
</style>


