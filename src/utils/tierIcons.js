/**
 * Battle Tier Icons Mapping
 * 根据段位名称返回对应的图标路径
 * 
 * 图标文件应存放在: public/images/tiers/（访问路径 /images/tiers/）
 * 命名格式: {tier_name_en}.png 或 {tier_name_en}.svg
 * 
 * 例如:
 * - bronze_iii.png
 * - silver_iii.png
 * - gold_iv.png
 * - diamond_v.png
 * - hall_of_fame.png
 */

// Tier icon mapping based on the design image
// 根据设计图片的段位图标映射
const tierIconMap = {
  // Bronze Tiers (青铜段位)
  'bronze_iii': '/images/tiers/bronze_iii.png',
  'bronze_ii': '/images/tiers/bronze_ii.png',
  'bronze_i': '/images/tiers/bronze_i.png',
  
  // Silver Tiers (白银段位)
  'silver_iii': '/images/tiers/silver_iii.png',
  'silver_ii': '/images/tiers/silver_ii.png',
  'silver_i': '/images/tiers/silver_i.png',
  
  // Gold Tiers (黄金段位)
  'gold_iv': '/images/tiers/gold_iv.png',
  'gold_iii': '/images/tiers/gold_iii.png',
  'gold_ii': '/images/tiers/gold_ii.png',
  'gold_i': '/images/tiers/gold_i.png',
  
  // Platinum Tiers (铂金段位)
  'platinum_iv': '/images/tiers/platinum_iv.png',
  'platinum_iii': '/images/tiers/platinum_iii.png',
  'platinum_ii': '/images/tiers/platinum_ii.png',
  'platinum_i': '/images/tiers/platinum_i.png',
  
  // Diamond Tiers (钻石段位)
  'diamond_v': '/images/tiers/diamond_v.png',
  'diamond_iv': '/images/tiers/diamond_iv.png',
  'diamond_iii': '/images/tiers/diamond_iii.png',
  'diamond_ii': '/images/tiers/diamond_ii.png',
  'diamond_i': '/images/tiers/diamond_i.png',
  
  // Master Tiers (大师段位)
  'star_glory_v': '/images/tiers/master_v.png',
  'star_glory_iv': '/images/tiers/master_iv.png',
  'star_glory_iii': '/images/tiers/master_iii.png',
  'star_glory_ii': '/images/tiers/master_ii.png',
  'star_glory_i': '/images/tiers/master_i.png',
  
  // King Tiers (杆王段位)
  'king_strongest': '/images/tiers/grand_master.png',
  'king_peerless': '/images/tiers/the_king.png',
  'king_glory': '/images/tiers/legend.png',
  'king_legendary': '/images/tiers/hall_of_fame.png'
}

// Fallback emoji icons (if image not found)
// 备用表情图标（如果图片未找到）
const tierEmojiMap = {
  'bronze_iii': '🛡️',
  'bronze_ii': '🛡️',
  'bronze_i': '🛡️',
  'silver_iii': '⚔️',
  'silver_ii': '⚔️',
  'silver_i': '⚔️',
  'gold_iv': '⭐',
  'gold_iii': '⭐',
  'gold_ii': '⭐',
  'gold_i': '⭐',
  'platinum_iv': '💎',
  'platinum_iii': '💎',
  'platinum_ii': '💎',
  'platinum_i': '💎',
  'diamond_v': '💠',
  'diamond_iv': '💠',
  'diamond_iii': '💠',
  'diamond_ii': '💠',
  'diamond_i': '💠',
  'star_glory_v': '🌟',
  'star_glory_iv': '🌟',
  'star_glory_iii': '🌟',
  'star_glory_ii': '🌟',
  'star_glory_i': '🌟',
  'king_strongest': '👑',
  'king_peerless': '👑',
  'king_glory': '👑',
  'king_legendary': '👑'
}

/**
 * Get tier icon path
 * @param {string} tierName - Tier name (e.g., 'bronze_iii', 'gold_i')
 * @returns {string} Icon path
 */
export function getTierIcon(tierName) {
  if (!tierName) return null
  const normalizedTier = tierName.toLowerCase()
  return tierIconMap[normalizedTier] || null
}

/**
 * Get tier emoji (fallback)
 * @param {string} tierName - Tier name
 * @returns {string} Emoji icon
 */
export function getTierEmoji(tierName) {
  if (!tierName) return '🎱'
  const normalizedTier = tierName.toLowerCase()
  return tierEmojiMap[normalizedTier] || '🎱'
}

/**
 * Get tier icon with fallback
 * Returns object with both image path and emoji fallback
 * @param {string} tierName - Tier name
 * @returns {object} { src: string, emoji: string }
 */
export function getTierIconWithFallback(tierName) {
  return {
    src: getTierIcon(tierName),
    emoji: getTierEmoji(tierName)
  }
}

/**
 * Tier display names mapping
 */
export const tierDisplayNames = {
  'bronze_iii': 'Bronze III',
  'bronze_ii': 'Bronze II',
  'bronze_i': 'Bronze I',
  'silver_iii': 'Silver III',
  'silver_ii': 'Silver II',
  'silver_i': 'Silver I',
  'gold_iv': 'Gold IV',
  'gold_iii': 'Gold III',
  'gold_ii': 'Gold II',
  'gold_i': 'Gold I',
  'platinum_iv': 'Platinum IV',
  'platinum_iii': 'Platinum III',
  'platinum_ii': 'Platinum II',
  'platinum_i': 'Platinum I',
  'diamond_v': 'Diamond V',
  'diamond_iv': 'Diamond IV',
  'diamond_iii': 'Diamond III',
  'diamond_ii': 'Diamond II',
  'diamond_i': 'Diamond I',
  'star_glory_v': 'Master V',
  'star_glory_iv': 'Master IV',
  'star_glory_iii': 'Master III',
  'star_glory_ii': 'Master II',
  'star_glory_i': 'Master I',
  'king_strongest': 'Grand Master',
  'king_peerless': 'The King',
  'king_glory': 'Legend',
  'king_legendary': 'Hall of Fame'
}
