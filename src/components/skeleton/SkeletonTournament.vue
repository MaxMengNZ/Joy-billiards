<template>
  <div class="skeleton-tournament">
    <!-- Tournament Header -->
    <div class="skeleton-tournament-header">
      <SkeletonBase width="60%" height="36px" class="skeleton-title" />
      <SkeletonBase width="40%" height="24px" class="skeleton-subtitle" />
      <div class="skeleton-meta">
        <SkeletonBase width="150px" height="20px" />
        <SkeletonBase width="120px" height="20px" />
        <SkeletonBase width="180px" height="20px" />
      </div>
    </div>
    
    <!-- Tournament Cards Grid -->
    <div class="skeleton-tournament-grid">
      <div 
        v-for="i in cardCount" 
        :key="i" 
        class="skeleton-tournament-card"
      >
        <SkeletonBase height="180px" class="skeleton-card-image" />
        <div class="skeleton-card-content">
          <SkeletonBase width="80%" height="24px" class="skeleton-card-title" />
          <SkeletonBase width="60%" height="18px" class="skeleton-card-subtitle" />
          <div class="skeleton-card-info">
            <SkeletonBase width="100px" height="16px" />
            <SkeletonBase width="80px" height="16px" />
          </div>
          <SkeletonBase width="100%" height="40px" rounded class="skeleton-card-button" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'

defineProps({
  cardCount: {
    type: Number,
    default: 6
  }
})
</script>

<style scoped>
.skeleton-tournament {
  padding: 2rem;
}

.skeleton-tournament-header {
  margin-bottom: 3rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.skeleton-meta {
  display: flex;
  gap: 2rem;
  margin-top: 1rem;
}

.skeleton-tournament-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 2rem;
}

.skeleton-tournament-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skeleton-card-image {
  border-radius: 0;
}

.skeleton-card-content {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.skeleton-card-info {
  display: flex;
  gap: 1rem;
  margin-top: 0.5rem;
}

.skeleton-card-button {
  margin-top: 1rem;
}
</style>


