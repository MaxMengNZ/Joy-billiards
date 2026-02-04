-- ============================================
-- Update Elo Trigger to Include Streak Rewards
-- 更新 Elo 触发器以包含连胜奖励
-- ============================================
-- This migration updates the update_elo_after_battle_room_complete function
-- to automatically check and award streak rewards when a player wins
-- 此迁移更新 update_elo_after_battle_room_complete 函数
-- 以在玩家获胜时自动检查并发放连胜奖励
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
    reward_result JSONB;
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
    
    -- Check and award streak rewards (only if streak increased and counts)
    IF winner_should_count_streak AND winner_new_streak IN (3, 5, 7, 10) THEN
        SELECT check_and_award_streak_rewards(winner_id_val, winner_new_streak) INTO reward_result;
        -- Note: Reward result is logged but not used further in trigger
        -- Frontend can query battle_streak_rewards table to show notifications
    END IF;
    
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
'Updates Elo ratings after battle room completion. Implements tier protection, Win Streak System, and automatic streak reward distribution. Checks and awards rewards when streak reaches 3, 5, 7, or 10 (once per season per threshold).';
