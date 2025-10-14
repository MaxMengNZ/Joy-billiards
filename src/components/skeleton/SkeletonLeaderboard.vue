<template>
  <div class="skeleton-leaderboard">
    <!-- Tabs -->
    <div class="skeleton-tabs">
      <SkeletonBase width="120px" height="40px" rounded />
      <SkeletonBase width="150px" height="40px" rounded />
      <SkeletonBase width="140px" height="40px" rounded />
    </div>
    
    <!-- Podium -->
    <div class="skeleton-podium">
      <!-- 2nd Place -->
      <div class="skeleton-podium-item skeleton-second">
        <SkeletonBase width="80px" height="80px" circle />
        <SkeletonBase width="100px" height="24px" />
        <SkeletonBase width="80px" height="20px" />
      </div>
      
      <!-- 1st Place -->
      <div class="skeleton-podium-item skeleton-first">
        <SkeletonBase width="100px" height="100px" circle />
        <SkeletonBase width="120px" height="28px" />
        <SkeletonBase width="100px" height="24px" />
      </div>
      
      <!-- 3rd Place -->
      <div class="skeleton-podium-item skeleton-third">
        <SkeletonBase width="80px" height="80px" circle />
        <SkeletonBase width="100px" height="24px" />
        <SkeletonBase width="80px" height="20px" />
      </div>
    </div>
    
    <!-- Rankings List -->
    <div class="skeleton-rankings">
      <div 
        v-for="i in 7" 
        :key="i" 
        class="skeleton-ranking-item"
      >
        <SkeletonBase width="40px" height="40px" class="skeleton-rank" />
        <SkeletonBase width="48px" height="48px" circle />
        <div class="skeleton-player-info">
          <SkeletonBase width="60%" height="20px" />
          <SkeletonBase width="40%" height="16px" />
        </div>
        <SkeletonBase width="80px" height="32px" rounded />
      </div>
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'
</script>

<style scoped>
.skeleton-leaderboard {
  padding: 2rem;
}

.skeleton-tabs {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 3rem;
}

.skeleton-podium {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  gap: 2rem;
  margin-bottom: 3rem;
  padding: 2rem;
}

.skeleton-podium-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.skeleton-first {
  transform: scale(1.1);
}

.skeleton-rankings {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-width: 800px;
  margin: 0 auto;
}

.skeleton-ranking-item {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  padding: 1.5rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.skeleton-rank {
  flex-shrink: 0;
}

.skeleton-player-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
</style>


