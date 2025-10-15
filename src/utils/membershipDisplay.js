/**
 * Membership Display Utilities
 * Smart display of membership levels based on available space
 */

/**
 * Format membership level for display
 * @param {string} level - Membership level (lite, plus, pro, pro_max)
 * @param {boolean} compact - Whether to use compact format (Pro M instead of Pro Max)
 * @returns {string} Formatted membership level name
 */
export function formatMembershipLevel(level, compact = false) {
  const levels = {
    lite: 'Lite',
    plus: 'Plus',
    pro: 'Pro',
    pro_max: compact ? 'Pro M' : 'Pro Max'
  }
  
  return levels[level] || 'Unknown'
}

/**
 * Get membership icon
 * @param {string} level - Membership level
 * @returns {string} Icon emoji
 */
export function getMembershipIcon(level) {
  const icons = {
    lite: '🎱',
    plus: '⭐',
    pro: '💎',
    pro_max: '🌟'
  }
  
  return icons[level] || '🎱'
}

/**
 * Format membership with icon
 * @param {string} level - Membership level
 * @param {boolean} compact - Whether to use compact format
 * @returns {string} Formatted string with icon
 */
export function formatMembershipWithIcon(level, compact = false) {
  const icon = getMembershipIcon(level)
  const name = formatMembershipLevel(level, compact)
  return `${icon} ${name}`
}

/**
 * Check if should use compact format based on viewport width
 * @returns {boolean} True if should use compact format
 */
export function shouldUseCompactFormat() {
  return window.innerWidth <= 768
}

/**
 * Get responsive membership display
 * Automatically chooses compact or full format based on viewport
 * @param {string} level - Membership level
 * @returns {string} Formatted membership level
 */
export function getResponsiveMembershipLevel(level) {
  const compact = shouldUseCompactFormat()
  return formatMembershipLevel(level, compact)
}

/**
 * Get responsive membership with icon
 * @param {string} level - Membership level
 * @returns {string} Formatted membership with icon
 */
export function getResponsiveMembershipWithIcon(level) {
  const compact = shouldUseCompactFormat()
  return formatMembershipWithIcon(level, compact)
}

