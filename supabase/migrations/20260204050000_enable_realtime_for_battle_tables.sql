-- ============================================
-- Enable Realtime for Battle Tables
-- 为 Battle 表启用实时更新
-- ============================================
-- This migration enables Supabase Realtime replication for Battle-related tables
-- This allows real-time updates when rooms or scores change
-- 此迁移为 Battle 相关表启用 Supabase Realtime 复制
-- 这允许在房间或得分变化时进行实时更新
-- ============================================

-- Enable Realtime for battle_rooms table
ALTER PUBLICATION supabase_realtime ADD TABLE battle_rooms;

-- Enable Realtime for battle_match_scores table (for score updates during matches)
ALTER PUBLICATION supabase_realtime ADD TABLE battle_match_scores;

-- ============================================
-- Comments
-- ============================================
COMMENT ON TABLE battle_rooms IS 'Battle rooms table with Realtime enabled for live updates';
COMMENT ON TABLE battle_match_scores IS 'Battle match scores table with Realtime enabled for live score updates';
