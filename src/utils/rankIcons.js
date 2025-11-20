/**
 * 段位图标工具函数
 * 将段位等级映射到对应的PNG图标路径
 */

const rankIconMap = {
  'hall_of_fame': '/rank-icons/hall_of_fame.png',
  'pro_level': '/rank-icons/pro_level.png',
  'grand_master': '/rank-icons/grand_master.png',
  'master': '/rank-icons/master.png',
  'elite': '/rank-icons/elite.png',
  'expert': '/rank-icons/expert.png',
  'advance': '/rank-icons/advance.png',
  'intermediate': '/rank-icons/intermediate.png',
  'beginner': '/rank-icons/beginner.png'
}

/**
 * 获取段位图标路径
 * @param {string} level - 段位等级 (如 'hall_of_fame', 'pro_level' 等)
 * @returns {string} 图标路径，如果不存在则返回默认图标
 */
export function getRankIconPath(level) {
  if (!level) return '/rank-icons/beginner.png' // 默认图标
  return rankIconMap[level] || '/rank-icons/beginner.png'
}

/**
 * 获取段位图标，带fallback到emoji
 * @param {string} level - 段位等级
 * @returns {Object} { src: string, alt: string, emoji: string }
 */
export function getRankIcon(level) {
  const emojiMap = {
    'hall_of_fame': '👑',
    'pro_level': '💎',
    'grand_master': '🌟',
    'master': '⭐',
    'elite': '🔷',
    'expert': '🔶',
    'advance': '🔺',
    'intermediate': '🔸',
    'beginner': '⚪'
  }
  
  return {
    src: getRankIconPath(level),
    alt: `${level} rank icon`,
    emoji: emojiMap[level] || '⚪'
  }
}

