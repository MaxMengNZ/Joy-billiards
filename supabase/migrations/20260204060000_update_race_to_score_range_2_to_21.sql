-- ============================================
-- Update Race To Score Range: 2-21
-- 更新比赛局数范围：2-21
-- ============================================
-- Change the valid range for race_to_score from 4-15 to 2-21
-- 将 race_to_score 的有效范围从 4-15 改为 2-21
-- ============================================

-- Drop existing constraint if exists
ALTER TABLE battle_rooms
DROP CONSTRAINT IF EXISTS battle_rooms_race_to_score_check;

-- Add new constraint for range 2-21
ALTER TABLE battle_rooms
ADD CONSTRAINT battle_rooms_race_to_score_check 
CHECK (race_to_score >= 2 AND race_to_score <= 21);

-- ============================================
-- Comments
-- ============================================
COMMENT ON COLUMN battle_rooms.race_to_score IS 'Race to X games (2-21). The number of games a player must win to win the match.';
