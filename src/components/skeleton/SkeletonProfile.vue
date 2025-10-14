<template>
  <div class="skeleton-profile">
    <!-- Profile Header -->
    <div class="skeleton-profile-header">
      <SkeletonBase width="120px" height="120px" circle class="skeleton-avatar" />
      <div class="skeleton-user-info">
        <SkeletonBase width="200px" height="32px" class="skeleton-name" />
        <SkeletonBase width="150px" height="20px" class="skeleton-email" />
        <div class="skeleton-badges">
          <SkeletonBase width="100px" height="28px" rounded />
          <SkeletonBase width="120px" height="28px" rounded />
        </div>
      </div>
    </div>
    
    <!-- Stats Grid -->
    <div class="skeleton-stats-grid">
      <div 
        v-for="i in 4" 
        :key="i" 
        class="skeleton-stat-card"
      >
        <SkeletonBase width="48px" height="48px" circle />
        <SkeletonBase width="80%" height="36px" />
        <SkeletonBase width="60%" height="18px" />
      </div>
    </div>
    
    <!-- Info Cards -->
    <div class="skeleton-info-section">
      <SkeletonBase width="200px" height="28px" class="skeleton-section-title" />
      <div class="skeleton-info-grid">
        <div 
          v-for="i in 6" 
          :key="i" 
          class="skeleton-info-item"
        >
          <SkeletonBase width="40%" height="18px" />
          <SkeletonBase width="70%" height="20px" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'
</script>

<style scoped>
.skeleton-profile {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.skeleton-profile-header {
  display: flex;
  align-items: center;
  gap: 2rem;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  margin-bottom: 2rem;
}

.skeleton-user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.skeleton-badges {
  display: flex;
  gap: 1rem;
  margin-top: 0.5rem;
}

.skeleton-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.skeleton-stat-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skeleton-info-section {
  background: white;
  border-radius: 16px;
  padding: 2rem;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skeleton-section-title {
  margin-bottom: 2rem;
}

.skeleton-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.skeleton-info-item {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
</style>


