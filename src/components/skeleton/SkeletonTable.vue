<template>
  <div class="skeleton-table">
    <!-- Table Header -->
    <div class="skeleton-table-header">
      <SkeletonBase 
        v-for="i in columns" 
        :key="`header-${i}`" 
        :width="`${100 / columns}%`" 
        height="20px"
      />
    </div>
    
    <!-- Table Rows -->
    <div 
      v-for="row in rows" 
      :key="`row-${row}`" 
      class="skeleton-table-row"
    >
      <SkeletonBase 
        v-for="col in columns" 
        :key="`cell-${row}-${col}`" 
        :width="`${100 / columns}%`" 
        height="18px"
      />
    </div>
  </div>
</template>

<script setup>
import SkeletonBase from './SkeletonBase.vue'

defineProps({
  rows: {
    type: Number,
    default: 5
  },
  columns: {
    type: Number,
    default: 4
  }
})
</script>

<style scoped>
.skeleton-table {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.skeleton-table-header {
  display: flex;
  gap: 1rem;
  padding-bottom: 1rem;
  border-bottom: 2px solid #f0f0f0;
  margin-bottom: 1rem;
}

.skeleton-table-row {
  display: flex;
  gap: 1rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid #f5f5f5;
}

.skeleton-table-row:last-child {
  border-bottom: none;
}
</style>


