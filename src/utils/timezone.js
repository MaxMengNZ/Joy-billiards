/**
 * New Zealand Timezone Utilities
 * 新西兰时区工具 - 统一处理所有时间显示和存储
 */

const NZ_TIMEZONE = 'Pacific/Auckland'

/**
 * 获取当前新西兰时间
 */
export function getNZDate() {
  return new Date(new Date().toLocaleString("en-US", { timeZone: NZ_TIMEZONE }))
}

/**
 * 将任意日期转换为新西兰时区的 Date 对象
 * @param {Date|string} date - 日期对象或 ISO 字符串
 * @returns {Date} 新西兰时区的 Date 对象
 */
export function toNZDate(date) {
  if (!date) return null
  const d = typeof date === 'string' ? new Date(date) : date
  return new Date(d.toLocaleString("en-US", { timeZone: NZ_TIMEZONE }))
}

/**
 * 格式化日期为新西兰时间显示
 * @param {Date|string} date - 日期
 * @param {Object} options - Intl.DateTimeFormat options
 * @returns {string} 格式化的日期字符串
 */
export function formatNZDate(date, options = {}) {
  if (!date) return 'N/A'
  
  const d = typeof date === 'string' ? new Date(date) : date
  
  const defaultOptions = {
    timeZone: NZ_TIMEZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }
  
  return new Intl.DateTimeFormat('en-NZ', { ...defaultOptions, ...options }).format(d)
}

/**
 * 格式化日期为短格式（仅日期）
 * @param {Date|string} date
 * @returns {string} 如："03/11/2025"
 */
export function formatNZDateShort(date) {
  return formatNZDate(date, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

/**
 * 格式化日期为时间格式（仅时间）
 * @param {Date|string} date
 * @returns {string} 如："14:30"
 */
export function formatNZTime(date) {
  return formatNZDate(date, {
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  })
}

/**
 * 格式化为完整日期时间
 * @param {Date|string} date
 * @returns {string} 如："Saturday, 2 November 2025, 14:30"
 */
export function formatNZDateTimeFull(date) {
  if (!date) return 'N/A'
  
  const d = typeof date === 'string' ? new Date(date) : date
  
  return new Intl.DateTimeFormat('en-NZ', {
    timeZone: NZ_TIMEZONE,
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }).format(d)
}

/**
 * 获取新西兰当前年份
 */
export function getNZYear() {
  const nzDate = getNZDate()
  return nzDate.getFullYear()
}

/**
 * 获取新西兰当前月份（1-12）
 */
export function getNZMonth() {
  const nzDate = getNZDate()
  return nzDate.getMonth() + 1
}

/**
 * 获取新西兰当前月份名称
 */
export function getNZMonthName() {
  const nzDate = getNZDate()
  return nzDate.toLocaleString('en-NZ', { month: 'long', timeZone: NZ_TIMEZONE })
}

/**
 * 获取新西兰「今天」的起止时间（UTC ISO 字符串，用于筛选「今日完成」等）
 * @returns {{ startISO: string, endISO: string }}
 */
export function getTodayNZStartEnd() {
  const nzDateStr = new Date().toLocaleDateString('en-CA', { timeZone: NZ_TIMEZONE })
  const [y, m, d] = nzDateStr.split('-').map(Number)
  const noonUTC = new Date(Date.UTC(y, m - 1, d, 12, 0, 0, 0))
  const aucklandHour = parseInt(
    new Intl.DateTimeFormat('en-US', { timeZone: NZ_TIMEZONE, hour: '2-digit', hour12: false }).format(noonUTC),
    10
  )
  const aucklandDay = parseInt(
    new Intl.DateTimeFormat('en-US', { timeZone: NZ_TIMEZONE, day: 'numeric' }).format(noonUTC),
    10
  )
  const offsetHours = (aucklandDay - d) * 24 + aucklandHour - 12
  const startUTC = new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0) - offsetHours * 60 * 60 * 1000)
  const endUTC = new Date(startUTC.getTime() + 24 * 60 * 60 * 1000 - 1)
  return { startISO: startUTC.toISOString(), endISO: endUTC.toISOString() }
}

/**
 * 创建新西兰时区的日期选择器值
 * @param {Date|string} date
 * @returns {string} ISO格式字符串（用于 input[type="datetime-local"]）
 */
export function toNZDateTimeLocalValue(date) {
  if (!date) return ''
  
  const d = typeof date === 'string' ? new Date(date) : date
  const nzDate = toNZDate(d)
  
  // Format: YYYY-MM-DDThh:mm
  const year = nzDate.getFullYear()
  const month = String(nzDate.getMonth() + 1).padStart(2, '0')
  const day = String(nzDate.getDate()).padStart(2, '0')
  const hours = String(nzDate.getHours()).padStart(2, '0')
  const minutes = String(nzDate.getMinutes()).padStart(2, '0')
  
  return `${year}-${month}-${day}T${hours}:${minutes}`
}

/**
 * 从日期选择器值创建 UTC 日期（供 Supabase 存储）
 * @param {string} localValue - datetime-local input 的值（新西兰本地时间）
 * @returns {string} ISO 字符串（UTC）
 * 
 * 示例：用户选择 "2025-11-02T14:30" (新西兰时间2点半)
 * → 应该存储为 "2025-11-02T01:30:00.000Z" (UTC时间，因为NZDT是UTC+13)
 */
export function fromNZDateTimeLocalValue(localValue) {
  if (!localValue) return null
  
  // 用户输入格式：2025-11-02T14:30
  // 这是他们在新西兰看到的时间
  
  // 简单粗暴但正确的方法：
  // 将这个字符串当作新西兰时间来解析
  const dateString = localValue.replace('T', ' ')
  const nzTimeString = `${dateString}:00 GMT+1300`  // NZDT是GMT+13，NZST是GMT+12
  
  // 更好的方法：检测当前是夏令时还是标准时间
  const testDate = new Date()
  const nzTestString = testDate.toLocaleString('en-US', { timeZone: 'Pacific/Auckland' })
  const utcTestString = testDate.toLocaleString('en-US', { timeZone: 'UTC' })
  const offset = (new Date(nzTestString) - new Date(utcTestString)) / (1000 * 60 * 60)  // 小时差
  
  // 解析用户输入
  const [datePart, timePart] = localValue.split('T')
  const [year, month, day] = datePart.split('-').map(Number)
  const [hour, minute] = timePart.split(':').map(Number)
  
  // 创建一个假设为UTC的日期
  const utcDate = new Date(Date.UTC(year, month - 1, day, hour, minute, 0))
  
  // 减去新西兰时区偏移（转换为UTC）
  const correctedDate = new Date(utcDate.getTime() - (offset * 60 * 60 * 1000))
  
  return correctedDate.toISOString()
}

/**
 * 相对时间显示（如："2 hours ago"）
 * @param {Date|string} date
 * @returns {string}
 */
export function formatRelativeTime(date) {
  if (!date) return 'Never'
  
  const d = typeof date === 'string' ? new Date(date) : date
  const nzNow = getNZDate()
  const diffMs = nzNow - toNZDate(d)
  const diffMins = Math.floor(diffMs / (1000 * 60))
  const diffHours = Math.floor(diffMs / (1000 * 60 * 60))
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
  
  if (diffMins < 1) return 'Just now'
  if (diffMins < 60) return `${diffMins} minute${diffMins > 1 ? 's' : ''} ago`
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
  if (diffDays < 7) return `${diffDays} day${diffDays > 1 ? 's' : ''} ago`
  
  return formatNZDateShort(d)
}

export default {
  NZ_TIMEZONE,
  getNZDate,
  toNZDate,
  formatNZDate,
  formatNZDateShort,
  formatNZTime,
  formatNZDateTimeFull,
  getNZYear,
  getNZMonth,
  getNZMonthName,
  toNZDateTimeLocalValue,
  fromNZDateTimeLocalValue,
  formatRelativeTime
}

