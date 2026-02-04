-- ============================================
-- Implement Win Streak System
-- 实现连胜系统
-- ============================================
-- This migration implements the Battle Win Streak System as per documentation:
-- 此迁移实现 Battle 连胜系统，按照文档要求：
-- 1. current_win_streak: Only records consecutive wins (resets to 0 on loss)
-- 2. season_best_win_streak: Best streak achieved in current season
-- 3. Anti-cheat rules: Same opponent 24h limit, Elo gap > 400 restriction
-- ============================================

-- ============================================
-- Add Win Streak Fields to users table
-- ============================================
ALTER TABLE users
ADD COLUMN IF NOT EXISTS current_win_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS season_best_win_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_streak_reward_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS streak_rewards_claimed JSONB DEFAULT '{}'::jsonb;

COMMENT ON COLUMN users.current_win_streak IS 'Current consecutive win streak (resets to 0 on loss)';
COMMENT ON COLUMN users.season_best_win_streak IS 'Best win streak achieved in current season';
COMMENT ON COLUMN users.last_streak_reward_at IS 'Last time a streak reward was claimed';
COMMENT ON COLUMN users.streak_rewards_claimed IS 'JSON object tracking which streak reward thresholds have been claimed this season (e.g., {"3": true, "5": true})';

-- ============================================
-- Helper Function: Check if match counts for streak
-- ============================================
CREATE OR REPLACE FUNCTION should_count_for_streak(
    p_player_id UUID,
    p_opponent_id UUID,
    p_player_elo INTEGER,
    p_opponent_elo INTEGER,
    p_room_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    elo_gap INTEGER;
    recent_match_count INTEGER;
    min_race_to_score INTEGER := 2; -- Minimum valid race_to_score
    room_race_to_score INTEGER;
BEGIN
    -- Rule 1: Elo gap must be <= 400
    elo_gap := ABS(p_player_elo - p_opponent_elo);
    IF elo_gap > 400 THEN
        RETURN FALSE;
    END IF;
    
    -- Rule 2: Same opponent 24h limit - only 1 win per opponent per 24 hours counts
    SELECT COUNT(*) INTO recent_match_count
    FROM battle_rooms
    WHERE status = 'completed'
      AND winner_id = p_player_id
      AND (
          (player1_id = p_player_id AND player2_id = p_opponent_id) OR
          (player1_id = p_opponent_id AND player2_id = p_player_id)
      )
      AND completed_at > NOW() - INTERVAL '24 hours';
    
    IF recent_match_count > 0 THEN
        RETURN FALSE; -- Already have a win against this opponent in last 24h
    END IF;
    
    -- Rule 3: Check if room has valid race_to_score (minimum 2)
    SELECT race_to_score INTO room_race_to_score
    FROM battle_rooms
    WHERE id = p_room_id;
    
    IF room_race_to_score IS NULL OR room_race_to_score < min_race_to_score THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION should_count_for_streak IS 'Checks if a match should count for streak based on anti-cheat rules: Elo gap <= 400, same opponent 24h limit, valid race_to_score';

-- ============================================
-- Update Elo calculation function with Win Streak System
-- ============================================
CREATE OR REPLACE FUNCTION update_elo_after_battle_room_complete()
RETURNS TRIGGER AS $$
DECLARE
    winner_elo_before INTEGER;
    loser_elo_before INTEGER;
    elo_change INTEGER;
    winner_id_val UUID;
    loser_id_val UUID;
    winner_tier_before VARCHAR(50);
    loser_tier_before VARCHAR(50);
    tier_diff INTEGER;
    is_matchmaking BOOLEAN;
    loser_tier_config RECORD;
    loser_new_elo INTEGER;
    loser_tier_min_elo INTEGER;
    winner_should_count_streak BOOLEAN;
    winner_new_streak INTEGER;
    winner_current_streak INTEGER;
BEGIN
    -- Only process when status changes to 'completed'
    IF NEW.status != 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;
    
    -- Get winner and loser
    winner_id_val := NEW.winner_id;
    loser_id_val := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN NEW.player2_id 
        ELSE NEW.player1_id 
    END;
    
    -- Get unified Battle Elo ratings
    SELECT battle_elo_rating, battle_tier, current_win_streak INTO winner_elo_before, winner_tier_before, winner_current_streak
    FROM users WHERE id = winner_id_val;
    
    SELECT battle_elo_rating, battle_tier INTO loser_elo_before, loser_tier_before
    FROM users WHERE id = loser_id_val;
    
    -- Default to 1000 if null
    winner_elo_before := COALESCE(winner_elo_before, 1000);
    loser_elo_before := COALESCE(loser_elo_before, 1000);
    winner_current_streak := COALESCE(winner_current_streak, 0);
    
    -- Calculate Elo change
    elo_change := calculate_elo_change(winner_elo_before, loser_elo_before);
    
    -- Determine if this is matchmaking or challenge match
    SELECT get_tier_difference(winner_tier_before, loser_tier_before) INTO tier_diff;
    is_matchmaking := tier_diff <= 1;
    
    -- Get loser's tier configuration for protection check
    SELECT * INTO loser_tier_config
    FROM battle_tier_config
    WHERE tier_name_en = loser_tier_before;
    
    -- Calculate loser's new Elo (before protection)
    loser_new_elo := GREATEST(loser_elo_before - elo_change, 0);
    
    -- Apply tier protection: if tier has protection, Elo cannot drop below tier minimum
    IF loser_tier_config.star_protection = true AND loser_tier_config.elo_min IS NOT NULL THEN
        loser_tier_min_elo := loser_tier_config.elo_min;
        -- Ensure Elo doesn't drop below tier minimum
        loser_new_elo := GREATEST(loser_new_elo, loser_tier_min_elo);
    END IF;
    
    -- Check if match should count for streak (anti-cheat rules)
    winner_should_count_streak := should_count_for_streak(
        winner_id_val,
        loser_id_val,
        winner_elo_before,
        loser_elo_before,
        NEW.id
    );
    
    -- Calculate winner's new streak
    IF winner_should_count_streak THEN
        winner_new_streak := winner_current_streak + 1;
    ELSE
        winner_new_streak := winner_current_streak; -- No change if doesn't count
    END IF;
    
    -- Store Elo before/after
    NEW.player1_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_elo_before 
        ELSE loser_elo_before 
    END;
    NEW.player1_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_elo_before + elo_change 
        ELSE loser_new_elo
    END;
    NEW.player2_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_elo_before 
        ELSE loser_elo_before 
    END;
    NEW.player2_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_elo_before + elo_change 
        ELSE loser_new_elo
    END;
    NEW.elo_change := elo_change;
    
    -- Update winner's unified Battle Elo and stats
    UPDATE users SET 
        battle_elo_rating = battle_elo_rating + elo_change,
        battle_wins = COALESCE(battle_wins, 0) + 1,
        current_win_streak = winner_new_streak,
        season_best_win_streak = GREATEST(COALESCE(season_best_win_streak, 0), winner_new_streak),
        -- Keep old battle_streak for backward compatibility (can be removed later)
        battle_streak = CASE 
            WHEN battle_streak < 0 THEN winner_new_streak 
            ELSE winner_new_streak 
        END,
        last_battle_match_at = NOW()
    WHERE id = winner_id_val;
    
    -- Update loser's unified Battle Elo and stats (with tier protection)
    -- Loser's streak resets to 0
    UPDATE users SET 
        battle_elo_rating = loser_new_elo, -- Use protected Elo value
        battle_losses = COALESCE(battle_losses, 0) + 1,
        current_win_streak = 0, -- Reset to 0 on loss
        -- Keep old battle_streak for backward compatibility (can be removed later)
        battle_streak = CASE 
            WHEN battle_streak > 0 THEN -1 
            ELSE battle_streak - 1 
        END,
        last_battle_match_at = NOW()
    WHERE id = loser_id_val;
    
    -- Update tier and stars automatically via trigger (trigger_update_battle_tier)
    -- Update global positions
    PERFORM update_battle_positions();
    
    -- Insert into battle_match_history
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
        NULL,
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

COMMENT ON FUNCTION update_elo_after_battle_room_complete() IS 
'Updates Elo ratings after battle room completion. Implements tier protection and Win Streak System: current_win_streak (resets to 0 on loss), season_best_win_streak, with anti-cheat rules (Elo gap <= 400, same opponent 24h limit).';

-- ============================================
-- Initialize existing users' streak values
-- ============================================
-- Set current_win_streak based on battle_streak (if positive)
UPDATE users
SET 
    current_win_streak = CASE 
        WHEN battle_streak > 0 THEN battle_streak 
        ELSE 0 
    END,
    season_best_win_streak = CASE 
        WHEN battle_streak > 0 THEN battle_streak 
        ELSE 0 
    END
WHERE battle_streak IS NOT NULL;

-- ============================================
-- Comments
-- ============================================
COMMENT ON TABLE users IS 'Users table now includes Win Streak System: current_win_streak (resets to 0 on loss), season_best_win_streak (best in season), with anti-cheat protection.';
