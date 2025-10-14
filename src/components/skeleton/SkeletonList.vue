<template>
  <div class="skeleton-list">
    <div 
      v-for="i in items" 
      :key="i" 
      class="skeleton-list-item"
    >
      <SkeletonBase 
        v-if="hasAvatar" 
        :width="avatarSize" 
        :height="avatarSize" 
        circle 
        class="skeleton-avatar"
      />
      <div class="skeleton-list-content">
        <SkeletonBase width="70%" height="20px" class="skeleton-title" />
        <SkeletonBase width="90%" height="16px" class="skeleton-subtitle" />
        <SkeletonBase v-if="hasDescription" width="100%" height="14px" />
      </div>
      <SkeletonBase v-if="hasAction" width="80px" height="32px" rounded />
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'

defineProps({
  items: {
    type: Number,
    default: 5
  },
  hasAvatar: {
    type: Boolean,
    default: false
  },
  avatarSize: {
    type: [String, Number],
    default: 48
  },
  hasDescription: {
    type: Boolean,
    default: false
  },
  hasAction: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped>
.skeleton-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.skeleton-list-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.skeleton-avatar {
  flex-shrink: 0;
}

.skeleton-list-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.skeleton-title {
  margin-bottom: 0.25rem;
}
</style>


