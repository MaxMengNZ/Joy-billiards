export const CLUB_HOME_URL = 'https://club.joybilliards.co.nz/'
export const RANK_HOST = 'rank.joybilliards.co.nz'
export const LEGACY_RANK_OPERATOR_EMAIL = 'maxmengnz@qq.com'

export const isRankWebsiteHost = (hostname = '') =>
  String(hostname).trim().toLowerCase() === RANK_HOST

export const canUseLegacyRankWebsite = ({ user, profile } = {}) =>
  String(user?.email || '').trim().toLowerCase() === LEGACY_RANK_OPERATOR_EMAIL &&
  profile?.role === 'admin'

