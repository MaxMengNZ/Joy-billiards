<template>
  <div class="error-log-viewer" v-if="isOpen">
    <div class="log-overlay" @click="close"></div>
    <div class="log-panel">
      <div class="log-header">
        <h2>🐛 Error Log Viewer</h2>
        <div class="header-actions">
          <button @click="refresh" class="btn-icon" title="Refresh">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
          </button>
          <button @click="exportLog" class="btn-icon" title="Export Log">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
          </button>
          <button @click="clearLog" class="btn-icon" title="Clear Log">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
          </button>
          <button @click="close" class="btn-icon btn-close" title="Close">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
      </div>
      
      <div class="log-stats">
        <div class="stat-card">
          <div class="stat-value">{{ errorLog.length }}</div>
          <div class="stat-label">Total Errors</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ errorsByType.network }}</div>
          <div class="stat-label">Network</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ errorsByType.server }}</div>
          <div class="stat-label">Server</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ errorsByType.client }}</div>
          <div class="stat-label">Client</div>
        </div>
      </div>
      
      <div class="log-content">
        <div v-if="errorLog.length === 0" class="no-errors">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p>No errors logged</p>
        </div>
        
        <div v-else class="error-list">
          <div 
            v-for="(error, index) in errorLog" 
            :key="index" 
            class="error-entry"
            :class="`error-type-${error.type}`"
          >
            <div class="error-entry-header" @click="toggleExpand(index)">
              <div class="error-type-badge">{{ error.type }}</div>
              <div class="error-message">{{ error.message }}</div>
              <div class="error-time">{{ formatTime(error.timestamp) }}</div>
              <svg 
                class="expand-icon" 
                :class="{ expanded: expandedErrors.has(index) }"
                xmlns="http://www.w3.org/2000/svg" 
                fill="none" 
                viewBox="0 0 24 24" 
                stroke="currentColor"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </div>
            
            <div v-if="expandedErrors.has(index)" class="error-entry-details">
              <div class="detail-section">
                <h4>Context</h4>
                <pre>{{ JSON.stringify(error.context, null, 2) }}</pre>
              </div>
              <div class="detail-section" v-if="error.stack">
                <h4>Stack Trace</h4>
                <pre>{{ error.stack }}</pre>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { getErrorLog, clearErrorLog as clearErrors, exportErrorLog, ErrorTypes } from '@/utils/errorHandler'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const isOpen = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

const errorLog = ref([])
const expandedErrors = ref(new Set())

const errorsByType = computed(() => {
  return {
    network: errorLog.value.filter(e => e.type === ErrorTypes.NETWORK).length,
    server: errorLog.value.filter(e => e.type === ErrorTypes.SERVER).length,
    client: errorLog.value.filter(e => e.type === ErrorTypes.CLIENT).length,
    other: errorLog.value.filter(e => ![ErrorTypes.NETWORK, ErrorTypes.SERVER, ErrorTypes.CLIENT].includes(e.type)).length
  }
})

const refresh = () => {
  errorLog.value = getErrorLog()
}

const exportLog = () => {
  exportErrorLog()
}

const clearLog = () => {
  if (confirm('Are you sure you want to clear all error logs?')) {
    clearErrors()
    errorLog.value = []
    expandedErrors.value.clear()
  }
}

const close = () => {
  isOpen.value = false
}

const toggleExpand = (index) => {
  if (expandedErrors.value.has(index)) {
    expandedErrors.value.delete(index)
  } else {
    expandedErrors.value.add(index)
  }
}

const formatTime = (timestamp) => {
  return new Date(timestamp).toLocaleString()
}

// Refresh log when panel opens
watch(isOpen, (newValue) => {
  if (newValue) {
    refresh()
  }
})
</script>

<style scoped>
.error-log-viewer {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 10000;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fadeIn 0.2s;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.log-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(4px);
}

.log-panel {
  position: relative;
  width: 90%;
  max-width: 1200px;
  height: 80vh;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
  display: flex;
  flex-direction: column;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.log-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.log-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #1f2937;
}

.header-actions {
  display: flex;
  gap: 0.5rem;
}

.btn-icon {
  width: 36px;
  height: 36px;
  border: none;
  background: #f3f4f6;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-icon svg {
  width: 20px;
  height: 20px;
  color: #6b7280;
}

.btn-icon:hover {
  background: #e5e7eb;
}

.btn-close:hover {
  background: #fecaca;
}

.btn-close:hover svg {
  color: #dc2626;
}

.log-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: #f9fafb;
  border-bottom: 1px solid #e5e7eb;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  text-align: center;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
}

.stat-label {
  font-size: 0.875rem;
  color: #6b7280;
  margin-top: 0.25rem;
}

.log-content {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
}

.no-errors {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  color: #9ca3af;
}

.no-errors svg {
  width: 64px;
  height: 64px;
  margin-bottom: 1rem;
  color: #10b981;
}

.no-errors p {
  font-size: 1.125rem;
}

.error-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.error-entry {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
}

.error-entry-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  cursor: pointer;
  transition: background 0.2s;
}

.error-entry-header:hover {
  background: #f9fafb;
}

.error-type-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  white-space: nowrap;
}

.error-type-network .error-type-badge {
  background: #dbeafe;
  color: #1e40af;
}

.error-type-server .error-type-badge {
  background: #fecaca;
  color: #991b1b;
}

.error-type-client .error-type-badge {
  background: #fed7aa;
  color: #9a3412;
}

.error-message {
  flex: 1;
  color: #1f2937;
  font-weight: 500;
}

.error-time {
  font-size: 0.875rem;
  color: #6b7280;
  white-space: nowrap;
}

.expand-icon {
  width: 20px;
  height: 20px;
  color: #9ca3af;
  transition: transform 0.2s;
}

.expand-icon.expanded {
  transform: rotate(180deg);
}

.error-entry-details {
  padding: 0 1rem 1rem;
  border-top: 1px solid #e5e7eb;
  background: #f9fafb;
}

.detail-section {
  margin-top: 1rem;
}

.detail-section h4 {
  font-size: 0.875rem;
  font-weight: 600;
  color: #6b7280;
  margin: 0 0 0.5rem 0;
}

.detail-section pre {
  background: #1f2937;
  color: #f9fafb;
  padding: 1rem;
  border-radius: 6px;
  overflow-x: auto;
  font-size: 0.875rem;
  line-height: 1.5;
  margin: 0;
}

@media (max-width: 768px) {
  .log-panel {
    width: 95%;
    height: 90vh;
  }
  
  .log-stats {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .error-entry-header {
    flex-wrap: wrap;
  }
  
  .error-time {
    width: 100%;
    margin-top: 0.5rem;
  }
}
</style>


