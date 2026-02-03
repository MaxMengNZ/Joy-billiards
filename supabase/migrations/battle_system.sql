-- ============================================
-- Battle System Database Migration
-- Battle 对战系统数据库迁移
-- ============================================
-- This migration creates the Battle system tables and functions
-- 此迁移创建 Battle 对战系统的表和函数
-- ============================================

-- ============================================
-- TABLE: battle_challenges (对战挑战表)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_challenges (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenger_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    opponent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) CHECK (status IN ('pending', 'accepted', 'rejected', 'completed', 'cancelled')) DEFAULT 'pending',
    challenge_type VARCHAR(20) CHECK (challenge_type IN ('battle', 'friendly')) DEFAULT 'battle', -- Battle对战 / Friendly友谊赛
    division VARCHAR(20) CHECK (division IN ('pro', 'student')) NOT NULL,
    
    -- Match results (filled when completed) / 比赛结果（完成时填写）
    winner_id UUID REFERENCES users(id),
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    race_to_score INTEGER DEFAULT 5,
    
    -- Elo changes / Elo变化
    challenger_elo_before INTEGER,
    challenger_elo_after INTEGER,
    opponent_elo_before INTEGER,
    opponent_elo_after INTEGER,
    elo_change INTEGER, -- Winner's Elo change / 胜者的Elo变化
    
    -- Timestamps / 时间戳
    challenged_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    accepted_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE, -- Challenge expiration (7 days) / 挑战过期时间（7天）
    
    -- Notes / 备注
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT different_players CHECK (challenger_id != opponent_id)
);

-- Indexes / 索引
CREATE INDEX IF NOT EXISTS idx_battle_challenges_challenger ON battle_challenges(challenger_id);
CREATE INDEX IF NOT EXISTS idx_battle_challenges_opponent ON battle_challenges(opponent_id);
CREATE INDEX IF NOT EXISTS idx_battle_challenges_status ON battle_challenges(status);
CREATE INDEX IF NOT EXISTS idx_battle_challenges_division ON battle_challenges(division);
CREATE INDEX IF NOT EXISTS idx_battle_challenges_created_at ON battle_challenges(created_at DESC);

-- ============================================
-- TABLE: battle_match_history (Battle对战历史)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_match_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    challenge_id UUID NOT NULL REFERENCES battle_challenges(id) ON DELETE CASCADE,
    player1_id UUID NOT NULL REFERENCES users(id),
    player2_id UUID NOT NULL REFERENCES users(id),
    winner_id UUID NOT NULL REFERENCES users(id),
    division VARCHAR(20) NOT NULL,
    
    -- Scores / 比分
    player1_score INTEGER NOT NULL,
    player2_score INTEGER NOT NULL,
    race_to_score INTEGER DEFAULT 5,
    
    -- Elo changes / Elo变化
    player1_elo_before INTEGER NOT NULL,
    player1_elo_after INTEGER NOT NULL,
    player2_elo_before INTEGER NOT NULL,
    player2_elo_after INTEGER NOT NULL,
    
    -- Time / 时间
    played_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes / 索引
CREATE INDEX IF NOT EXISTS idx_battle_history_player1 ON battle_match_history(player1_id);
CREATE INDEX IF NOT EXISTS idx_battle_history_player2 ON battle_match_history(player2_id);
CREATE INDEX IF NOT EXISTS idx_battle_history_division ON battle_match_history(division);
CREATE INDEX IF NOT EXISTS idx_battle_history_played_at ON battle_match_history(played_at DESC);

-- ============================================
-- EXTEND users TABLE (扩展users表)
-- ============================================
-- ⚠️ Note: These fields are completely independent from tournament points system
-- ⚠️ 注意：这些字段与周赛积分系统完全独立

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS elo_rating_pro INTEGER DEFAULT 1000, -- Pro组Battle Elo
ADD COLUMN IF NOT EXISTS elo_rating_student INTEGER DEFAULT 1000, -- Student组Battle Elo
ADD COLUMN IF NOT EXISTS battle_position_pro INTEGER, -- Pro组Battle排名
ADD COLUMN IF NOT EXISTS battle_position_student INTEGER, -- Student组Battle排名
ADD COLUMN IF NOT EXISTS battle_wins_pro INTEGER DEFAULT 0, -- Pro组Battle胜场
ADD COLUMN IF NOT EXISTS battle_losses_pro INTEGER DEFAULT 0, -- Pro组Battle负场
ADD COLUMN IF NOT EXISTS battle_wins_student INTEGER DEFAULT 0, -- Student组Battle胜场
ADD COLUMN IF NOT EXISTS battle_losses_student INTEGER DEFAULT 0, -- Student组Battle负场
ADD COLUMN IF NOT EXISTS battle_streak INTEGER DEFAULT 0, -- 连胜/连败（当前组）
ADD COLUMN IF NOT EXISTS last_battle_match_at TIMESTAMP WITH TIME ZONE; -- 最后Battle对战时间

-- ⚠️ Important Notes / 重要说明：
-- - ranking_points: Tournament points (unchanged, continue using) / 周赛积分（不变，继续使用）
-- - ranking_level: Tournament rank (unchanged, continue using) / 周赛段位（不变，继续使用）
-- - elo_rating_*: Battle Elo (new, completely independent) / Battle Elo（新增，完全独立）
-- - battle_*: Battle statistics (new, completely independent) / Battle统计数据（新增，完全独立）

-- ============================================
-- FUNCTION: calculate_elo_change (Elo计算函数)
-- ============================================
CREATE OR REPLACE FUNCTION calculate_elo_change(
    winner_elo INTEGER,
    loser_elo INTEGER,
    k_factor INTEGER DEFAULT 32
) RETURNS INTEGER AS $$
DECLARE
    expected_score_winner NUMERIC;
    elo_change INTEGER;
BEGIN
    -- Calculate expected score / 计算期望得分
    expected_score_winner := 1.0 / (1.0 + POWER(10.0, (loser_elo - winner_elo) / 400.0));
    
    -- Calculate Elo change (for winner) / 计算Elo变化（胜者）
    elo_change := ROUND(k_factor * (1.0 - expected_score_winner));
    
    RETURN elo_change;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: update_elo_after_battle_match (更新Elo触发器函数)
-- ============================================
CREATE OR REPLACE FUNCTION update_elo_after_battle_match()
RETURNS TRIGGER AS $$
DECLARE
    winner_elo_before INTEGER;
    loser_elo_before INTEGER;
    elo_change INTEGER;
    winner_division_elo INTEGER;
    loser_division_elo INTEGER;
    winner_id_val UUID;
    loser_id_val UUID;
BEGIN
    -- Only process when status changes to 'completed' / 仅在状态变为'completed'时处理
    IF NEW.status != 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;
    
    -- Get winner and loser / 获取胜者和败者
    winner_id_val := NEW.winner_id;
    loser_id_val := CASE 
        WHEN NEW.winner_id = NEW.challenger_id THEN NEW.opponent_id 
        ELSE NEW.challenger_id 
    END;
    
    -- Get Elo ratings based on division / 根据组别获取Elo评分
    IF NEW.division = 'pro' THEN
        SELECT elo_rating_pro INTO winner_division_elo FROM users WHERE id = winner_id_val;
        SELECT elo_rating_pro INTO loser_division_elo FROM users WHERE id = loser_id_val;
    ELSE
        SELECT elo_rating_student INTO winner_division_elo FROM users WHERE id = winner_id_val;
        SELECT elo_rating_student INTO loser_division_elo FROM users WHERE id = loser_id_val;
    END IF;
    
    -- Calculate Elo change / 计算Elo变化
    elo_change := calculate_elo_change(winner_division_elo, loser_division_elo);
    
    -- Store Elo before / 存储Elo变化前
    IF NEW.winner_id = NEW.challenger_id THEN
        NEW.challenger_elo_before := winner_division_elo;
        NEW.challenger_elo_after := winner_division_elo + elo_change;
        NEW.opponent_elo_before := loser_division_elo;
        NEW.opponent_elo_after := loser_division_elo - elo_change;
    ELSE
        NEW.opponent_elo_before := winner_division_elo;
        NEW.opponent_elo_after := winner_division_elo + elo_change;
        NEW.challenger_elo_before := loser_division_elo;
        NEW.challenger_elo_after := loser_division_elo - elo_change;
    END IF;
    NEW.elo_change := elo_change;
    
    -- Update Elo and battle stats / 更新Elo和Battle统计数据
    IF NEW.division = 'pro' THEN
        -- Update winner / 更新胜者
        UPDATE users SET 
            elo_rating_pro = elo_rating_pro + elo_change,
            battle_wins_pro = COALESCE(battle_wins_pro, 0) + 1,
            last_battle_match_at = NOW()
        WHERE id = winner_id_val;
        
        -- Update loser / 更新败者
        UPDATE users SET 
            elo_rating_pro = elo_rating_pro - elo_change,
            battle_losses_pro = battle_losses_pro + 1,
            last_battle_match_at = NOW()
        WHERE id = loser_id_val;
    ELSE
        -- Update winner / 更新胜者
        UPDATE users SET 
            elo_rating_student = elo_rating_student + elo_change,
            battle_wins_student = battle_wins_student + 1,
            last_battle_match_at = NOW()
        WHERE id = winner_id_val;
        
        -- Update loser / 更新败者
        UPDATE users SET 
            elo_rating_student = elo_rating_student - elo_change,
            battle_losses_student = battle_losses_student + 1,
            last_battle_match_at = NOW()
        WHERE id = loser_id_val;
    END IF;
    
    -- Insert into battle_match_history / 插入Battle对战历史
    INSERT INTO battle_match_history (
        challenge_id,
        player1_id,
        player2_id,
        winner_id,
        division,
        player1_score,
        player2_score,
        race_to_score,
        player1_elo_before,
        player1_elo_after,
        player2_elo_before,
        player2_elo_after
    ) VALUES (
        NEW.id,
        NEW.challenger_id,
        NEW.opponent_id,
        NEW.winner_id,
        NEW.division,
        NEW.player1_score,
        NEW.player2_score,
        NEW.race_to_score,
        NEW.challenger_elo_before,
        NEW.challenger_elo_after,
        NEW.opponent_elo_before,
        NEW.opponent_elo_after
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: trigger_update_elo_after_battle_match
-- ============================================
DROP TRIGGER IF EXISTS trigger_update_elo_after_battle_match ON battle_challenges;
CREATE TRIGGER trigger_update_elo_after_battle_match
BEFORE UPDATE ON battle_challenges
FOR EACH ROW
WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
EXECUTE FUNCTION update_elo_after_battle_match();

-- ============================================
-- FUNCTION: update_battle_positions (更新Battle排名)
-- ============================================
CREATE OR REPLACE FUNCTION update_battle_positions()
RETURNS void AS $$
BEGIN
    -- Update Pro division positions / 更新Pro组排名
    WITH ranked_pro AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (ORDER BY elo_rating_pro DESC, battle_wins_pro DESC, battle_losses_pro ASC) as position
        FROM users
        WHERE elo_rating_pro > 0
    )
    UPDATE users u
    SET battle_position_pro = r.position
    FROM ranked_pro r
    WHERE u.id = r.id;
    
    -- Update Student division positions / 更新Student组排名
    WITH ranked_student AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (ORDER BY elo_rating_student DESC, battle_wins_student DESC, battle_losses_student ASC) as position
        FROM users
        WHERE elo_rating_student > 0
    )
    UPDATE users u
    SET battle_position_student = r.position
    FROM ranked_student r
    WHERE u.id = r.id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- RLS Policies (Row Level Security)
-- ============================================
ALTER TABLE battle_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE battle_match_history ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all challenges / 用户可以查看所有挑战
CREATE POLICY "Users can view battle challenges"
ON battle_challenges FOR SELECT
USING (true);

-- Policy: Users can create challenges / 用户可以创建挑战
CREATE POLICY "Users can create battle challenges"
ON battle_challenges FOR INSERT
WITH CHECK (auth.uid()::text = challenger_id::text);

-- Policy: Users can update their own challenges or challenges they received / 用户可以更新自己的挑战或收到的挑战
CREATE POLICY "Users can update battle challenges"
ON battle_challenges FOR UPDATE
USING (
    auth.uid()::text = challenger_id::text OR 
    auth.uid()::text = opponent_id::text
);

-- Policy: Users can view all battle history / 用户可以查看所有Battle历史
CREATE POLICY "Users can view battle history"
ON battle_match_history FOR SELECT
USING (true);

-- ============================================
-- Comments / 注释
-- ============================================
COMMENT ON TABLE battle_challenges IS 'Battle challenge records / Battle对战挑战记录';
COMMENT ON TABLE battle_match_history IS 'Battle match history / Battle对战历史';
COMMENT ON FUNCTION calculate_elo_change IS 'Calculate Elo rating change based on winner and loser ratings / 根据胜者和败者评分计算Elo变化';
COMMENT ON FUNCTION update_elo_after_battle_match IS 'Update Elo ratings after battle match completion / Battle对战完成后更新Elo评分';
COMMENT ON FUNCTION update_battle_positions IS 'Update Battle leaderboard positions / 更新Battle排行榜排名';
