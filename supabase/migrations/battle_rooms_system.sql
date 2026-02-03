-- ============================================
-- Battle Rooms System Database Migration
-- Battle 球房房间系统数据库迁移
-- ============================================
-- This migration creates the Battle Rooms system (game-style room system)
-- 此迁移创建 Battle 球房房间系统（游戏风格房间系统）
-- ============================================

-- ============================================
-- TABLE: battle_rooms (球局房间表)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_name VARCHAR(200) NOT NULL, -- Room name / 球局名字
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Room creator / 创建者
    player1_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- Player 1 / 玩家1
    player2_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Player 2 (can be null initially) / 玩家2（初始可为空）
    division VARCHAR(20) CHECK (division IN ('pro', 'student')) NOT NULL, -- Division / 组别
    
    -- Game settings / 比赛设置
    race_to_score INTEGER NOT NULL DEFAULT 5, -- Race to X (4,5,6,7,8,9...) / 抢局数
    scheduled_start_time TIMESTAMP WITH TIME ZONE, -- Scheduled start time / 开始时间
    
    -- Room status / 房间状态
    status VARCHAR(20) CHECK (status IN ('waiting', 'ready', 'in_progress', 'completed', 'cancelled')) DEFAULT 'waiting',
    -- waiting: 等待对手入座
    -- ready: 双方已确认，准备开始
    -- in_progress: 比赛进行中
    -- completed: 比赛已完成
    -- cancelled: 已取消
    
    -- Player confirmations / 玩家确认状态
    player1_ready BOOLEAN DEFAULT false, -- Player 1 ready to start / 玩家1确认开始
    player2_ready BOOLEAN DEFAULT false, -- Player 2 ready to start / 玩家2确认开始
    
    -- Match results / 比赛结果
    winner_id UUID REFERENCES users(id), -- Winner / 胜者
    player1_score INTEGER DEFAULT 0, -- Player 1 final score / 玩家1最终得分
    player2_score INTEGER DEFAULT 0, -- Player 2 final score / 玩家2最终得分
    
    -- Elo changes / Elo变化
    player1_elo_before INTEGER,
    player1_elo_after INTEGER,
    player2_elo_before INTEGER,
    player2_elo_after INTEGER,
    elo_change INTEGER, -- Winner's Elo change / 胜者的Elo变化
    
    -- Timestamps / 时间戳
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    started_at TIMESTAMP WITH TIME ZONE, -- When both players confirmed / 双方确认开始时间
    completed_at TIMESTAMP WITH TIME ZONE, -- When match completed / 比赛完成时间
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT different_players CHECK (player1_id != player2_id OR player2_id IS NULL)
);

-- Indexes / 索引
CREATE INDEX IF NOT EXISTS idx_battle_rooms_created_by ON battle_rooms(created_by);
CREATE INDEX IF NOT EXISTS idx_battle_rooms_player1 ON battle_rooms(player1_id);
CREATE INDEX IF NOT EXISTS idx_battle_rooms_player2 ON battle_rooms(player2_id);
CREATE INDEX IF NOT EXISTS idx_battle_rooms_status ON battle_rooms(status);
CREATE INDEX IF NOT EXISTS idx_battle_rooms_division ON battle_rooms(division);
CREATE INDEX IF NOT EXISTS idx_battle_rooms_created_at ON battle_rooms(created_at DESC);

-- ============================================
-- TABLE: battle_match_scores (比赛实时得分记录)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_match_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL REFERENCES battle_rooms(id) ON DELETE CASCADE,
    recorded_by UUID NOT NULL REFERENCES users(id), -- Who recorded this score / 谁记录的得分
    
    -- Score update / 得分更新
    player1_current_score INTEGER NOT NULL DEFAULT 0, -- Player 1 current score / 玩家1当前得分
    player2_current_score INTEGER NOT NULL DEFAULT 0, -- Player 2 current score / 玩家2当前得分
    
    -- Frame/Game information / 局/场次信息
    frame_number INTEGER DEFAULT 1, -- Current frame number / 当前局数
    is_frame_complete BOOLEAN DEFAULT false, -- Is this frame completed / 本局是否完成
    
    -- Notes / 备注
    notes TEXT, -- Additional notes (e.g., break and run, foul, etc.) / 额外备注（如：清台、犯规等）
    
    -- Timestamp / 时间戳
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes / 索引
CREATE INDEX IF NOT EXISTS idx_battle_scores_room ON battle_match_scores(room_id);
CREATE INDEX IF NOT EXISTS idx_battle_scores_recorded_by ON battle_match_scores(recorded_by);
CREATE INDEX IF NOT EXISTS idx_battle_scores_recorded_at ON battle_match_scores(recorded_at DESC);

-- ============================================
-- TABLE: battle_match_history (Battle对战历史 - 保留用于统计)
-- ============================================
-- Keep this table for historical records and statistics
-- 保留此表用于历史记录和统计

-- ============================================
-- FUNCTION: update_elo_after_battle_room_complete (更新Elo触发器函数 - 房间版)
-- ============================================
CREATE OR REPLACE FUNCTION update_elo_after_battle_room_complete()
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
        WHEN NEW.winner_id = NEW.player1_id THEN NEW.player2_id 
        ELSE NEW.player1_id 
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
    NEW.player1_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_division_elo 
        ELSE loser_division_elo 
    END;
    NEW.player1_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_division_elo + elo_change 
        ELSE GREATEST(loser_division_elo - elo_change, 0) 
    END;
    NEW.player2_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_division_elo 
        ELSE loser_division_elo 
    END;
    NEW.player2_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_division_elo + elo_change 
        ELSE GREATEST(loser_division_elo - elo_change, 0) 
    END;
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
            elo_rating_pro = GREATEST(elo_rating_pro - elo_change, 0),
            battle_losses_pro = COALESCE(battle_losses_pro, 0) + 1,
            last_battle_match_at = NOW()
        WHERE id = loser_id_val;
    ELSE
        -- Update winner / 更新胜者
        UPDATE users SET 
            elo_rating_student = elo_rating_student + elo_change,
            battle_wins_student = COALESCE(battle_wins_student, 0) + 1,
            last_battle_match_at = NOW()
        WHERE id = winner_id_val;
        
        -- Update loser / 更新败者
        UPDATE users SET 
            elo_rating_student = GREATEST(elo_rating_student - elo_change, 0),
            battle_losses_student = COALESCE(battle_losses_student, 0) + 1,
            last_battle_match_at = NOW()
        WHERE id = loser_id_val;
    END IF;
    
    -- Insert into battle_match_history / 插入Battle对战历史
    INSERT INTO battle_match_history (
        challenge_id, -- Will be NULL for room-based matches / 房间式比赛为NULL
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
        NULL, -- Room-based, no challenge_id / 房间式，无challenge_id
        NEW.player1_id,
        NEW.player2_id,
        NEW.winner_id,
        NEW.division,
        NEW.player1_score,
        NEW.player2_score,
        NEW.race_to_score,
        NEW.player1_elo_before,
        NEW.player1_elo_after,
        NEW.player2_elo_before,
        NEW.player2_elo_after
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: trigger_update_elo_after_battle_room_complete
-- ============================================
DROP TRIGGER IF EXISTS trigger_update_elo_after_battle_room_complete ON battle_rooms;
CREATE TRIGGER trigger_update_elo_after_battle_room_complete
BEFORE UPDATE ON battle_rooms
FOR EACH ROW
WHEN (NEW.status = 'completed' AND OLD.status != 'completed')
EXECUTE FUNCTION update_elo_after_battle_room_complete();

-- ============================================
-- FUNCTION: check_score_recording_permission (检查得分记录权限)
-- ============================================
CREATE OR REPLACE FUNCTION check_score_recording_permission(
    p_room_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    room_record RECORD;
    is_admin BOOLEAN;
BEGIN
    -- Get room info / 获取房间信息
    SELECT * INTO room_record
    FROM battle_rooms
    WHERE id = p_room_id;
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Check if user is admin / 检查用户是否为管理员
    SELECT role = 'admin' INTO is_admin
    FROM users
    WHERE id = p_user_id;
    
    -- Allow if: user is player1, player2, or admin / 允许：用户是玩家1、玩家2或管理员
    RETURN (
        room_record.player1_id = p_user_id OR
        room_record.player2_id = p_user_id OR
        (is_admin = true)
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- RLS Policies (Row Level Security)
-- ============================================
ALTER TABLE battle_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE battle_match_scores ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view all rooms / 用户可以查看所有房间
DROP POLICY IF EXISTS "Users can view battle rooms" ON battle_rooms;
CREATE POLICY "Users can view battle rooms"
ON battle_rooms FOR SELECT
USING (true);

-- Policy: Users can create rooms / 用户可以创建房间
DROP POLICY IF EXISTS "Users can create battle rooms" ON battle_rooms;
CREATE POLICY "Users can create battle rooms"
ON battle_rooms FOR INSERT
WITH CHECK (auth.uid()::text = created_by::text);

-- Policy: Users can update their own rooms or rooms they are in / 用户可以更新自己的房间或他们所在的房间
DROP POLICY IF EXISTS "Users can update battle rooms" ON battle_rooms;
CREATE POLICY "Users can update battle rooms"
ON battle_rooms FOR UPDATE
USING (
    auth.uid()::text = created_by::text OR 
    auth.uid()::text = player1_id::text OR 
    auth.uid()::text = player2_id::text OR
    EXISTS (
        SELECT 1 FROM users 
        WHERE id::text = auth.uid()::text AND role = 'admin'
    )
);

-- Policy: Users can view scores for rooms they are in or admin / 用户可以查看他们所在房间的得分或管理员
DROP POLICY IF EXISTS "Users can view battle scores" ON battle_match_scores;
CREATE POLICY "Users can view battle scores"
ON battle_match_scores FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM battle_rooms br
        WHERE br.id = battle_match_scores.room_id
        AND (
            br.player1_id::text = auth.uid()::text OR
            br.player2_id::text = auth.uid()::text OR
            EXISTS (
                SELECT 1 FROM users 
                WHERE id::text = auth.uid()::text AND role = 'admin'
            )
        )
    )
);

-- Policy: Only players in room or admin can record scores / 只有房间内的玩家或管理员可以记录得分
DROP POLICY IF EXISTS "Users can record battle scores" ON battle_match_scores;
CREATE POLICY "Users can record battle scores"
ON battle_match_scores FOR INSERT
WITH CHECK (
    check_score_recording_permission(room_id, auth.uid()::uuid)
);

-- ============================================
-- Comments / 注释
-- ============================================
COMMENT ON TABLE battle_rooms IS 'Battle room system - game-style room management / Battle球房房间系统 - 游戏风格房间管理';
COMMENT ON TABLE battle_match_scores IS 'Real-time score recording for battle rooms / Battle房间实时得分记录';
COMMENT ON FUNCTION check_score_recording_permission IS 'Check if user has permission to record scores in a room / 检查用户是否有权限在房间内记录得分';
