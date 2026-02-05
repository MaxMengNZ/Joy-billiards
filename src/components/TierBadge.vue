<template>
  <div class="tier-badge" :class="[`tier-${tier}`, sizeClass]">
    <div class="tier-icon-wrapper">
      <img
        v-if="iconData.src && !iconError"
        :src="iconData.src"
        :alt="displayName"
        class="tier-icon"
        @error="handleImageError"
      />
      <span v-else class="tier-icon-emoji">{{ iconData.emoji }}</span>
    </div>
    <div class="tier-info">
      <span class="tier-name">{{ displayName }}</span>
      <span v-if="stars > 0" class="tier-stars">
        {{ '⭐'.repeat(Math.min(stars, 5)) }}
      </span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { getTierIconWithFallback, tierDisplayNames } from '../utils/tierIcons.js'

const props = defineProps({
  tier: {
    type: String,
    required: true
  },
  stars: {
    type: Number,
    default: 0
  },
  size: {
    type: String,
    default: 'medium', // 'small', 'medium', 'large'
    validator: (value) => ['small', 'medium', 'large'].includes(value)
  }
})

const iconError = ref(false)

const iconData = computed(() => {
  return getTierIconWithFallback(props.tier)
})

const displayName = computed(() => {
  if (!props.tier) return 'Unranked'
  const normalizedTier = props.tier.toLowerCase()
  return tierDisplayNames[normalizedTier] || props.tier
})

const sizeClass = computed(() => {
  return `tier-badge-${props.size}`
})

const handleImageError = () => {
  iconError.value = true
}
</script>

<style scoped>
.tier-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 0.75rem;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.2s;
}

.tier-icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.tier-icon {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.tier-icon-emoji {
  font-size: 1.2em;
  line-height: 1;
}

.tier-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.tier-name {
  font-weight: 600;
  font-size: 0.9rem;
  color: white;
}

.tier-stars {
  font-size: 0.75rem;
  line-height: 1;
}

/* Size variants */
.tier-badge-small .tier-icon-wrapper {
  width: 24px;
  height: 24px;
}

.tier-badge-small .tier-name {
  font-size: 0.75rem;
}

.tier-badge-small .tier-stars {
  font-size: 0.65rem;
}

.tier-badge-medium .tier-icon-wrapper {
  width: 32px;
  height: 32px;
}

.tier-badge-large .tier-icon-wrapper {
  width: 48px;
  height: 48px;
}

.tier-badge-large .tier-name {
  font-size: 1rem;
}

.tier-badge-large .tier-stars {
  font-size: 0.85rem;
}

/* Tier-specific colors (can be customized) */
.tier-bronze_iii,
.tier-bronze_ii,
.tier-bronze_i {
  background: linear-gradient(135deg, rgba(205, 127, 50, 0.2), rgba(139, 69, 19, 0.2));
  border-color: rgba(205, 127, 50, 0.4);
}

.tier-silver_iii,
.tier-silver_ii,
.tier-silver_i {
  background: linear-gradient(135deg, rgba(192, 192, 192, 0.2), rgba(128, 128, 128, 0.2));
  border-color: rgba(192, 192, 192, 0.4);
}

.tier-gold_iv,
.tier-gold_iii,
.tier-gold_ii,
.tier-gold_i {
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.2), rgba(255, 140, 0, 0.2));
  border-color: rgba(255, 215, 0, 0.4);
}

.tier-platinum_iv,
.tier-platinum_iii,
.tier-platinum_ii,
.tier-platinum_i {
  background: linear-gradient(135deg, rgba(0, 206, 209, 0.2), rgba(0, 191, 255, 0.2));
  border-color: rgba(0, 206, 209, 0.4);
}

.tier-diamond_v,
.tier-diamond_iv,
.tier-diamond_iii,
.tier-diamond_ii,
.tier-diamond_i {
  background: linear-gradient(135deg, rgba(0, 0, 255, 0.2), rgba(0, 0, 139, 0.2));
  border-color: rgba(0, 0, 255, 0.4);
}

.tier-star_glory_v,
.tier-star_glory_iv,
.tier-star_glory_iii,
.tier-star_glory_ii,
.tier-star_glory_i {
  background: linear-gradient(135deg, rgba(138, 43, 226, 0.2), rgba(75, 0, 130, 0.2));
  border-color: rgba(138, 43, 226, 0.4);
}

.tier-king_strongest {
  background: linear-gradient(135deg, rgba(138, 43, 226, 0.3), rgba(75, 0, 130, 0.3));
  border-color: rgba(138, 43, 226, 0.5);
}

.tier-king_peerless {
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.3), rgba(255, 140, 0, 0.3));
  border-color: rgba(255, 215, 0, 0.5);
}

.tier-king_glory {
  background: linear-gradient(135deg, rgba(255, 165, 0, 0.3), rgba(255, 69, 0, 0.3));
  border-color: rgba(255, 165, 0, 0.5);
}

.tier-king_legendary {
  background: linear-gradient(135deg, rgba(255, 215, 0, 0.4), rgba(255, 140, 0, 0.4));
  border-color: rgba(255, 215, 0, 0.6);
}
</style>
