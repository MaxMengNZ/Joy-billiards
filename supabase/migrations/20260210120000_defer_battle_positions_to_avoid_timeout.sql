-- ============================================
-- Defer update_battle_positions out of trigger to fix submit timeout
-- 将全表排名更新移出触发器，避免提交比赛结果超时
-- ============================================
-- The trigger used to call update_battle_positions() which updates every user's
-- battle_position. On large user tables this can take 30-60+ seconds and cause
-- "Request timed out" when submitting match results.
-- Frontend will call update_battle_positions() in the background after success.
-- 触发器不再执行 update_battle_positions()，由前端在提交成功后后台调用。
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
    IF NEW.status != 'completed' OR OLD.status = 'completed' THEN
        RETURN NEW;
    END IF;

    winner_id_val := NEW.winner_id;
    loser_id_val := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN NEW.player2_id 
        ELSE NEW.player1_id 
    END;

    SELECT battle_elo_rating, battle_tier, current_win_streak INTO winner_elo_before, winner_tier_before, winner_current_streak
    FROM users WHERE id = winner_id_val;

    SELECT battle_elo_rating, battle_tier INTO loser_elo_before, loser_tier_before
    FROM users WHERE id = loser_id_val;

    winner_elo_before := COALESCE(winner_elo_before, 1000);
    loser_elo_before := COALESCE(loser_elo_before, 1000);
    winner_current_streak := COALESCE(winner_current_streak, 0);

    elo_change := calculate_elo_change(winner_elo_before, loser_elo_before);

    SELECT get_tier_difference(winner_tier_before, loser_tier_before) INTO tier_diff;
    is_matchmaking := tier_diff <= 1;

    SELECT * INTO loser_tier_config
    FROM battle_tier_config
    WHERE tier_name_en = loser_tier_before;

    loser_new_elo := GREATEST(loser_elo_before - elo_change, 0);

    IF loser_tier_config.star_protection = true AND loser_tier_config.elo_min IS NOT NULL THEN
        loser_tier_min_elo := loser_tier_config.elo_min;
        loser_new_elo := GREATEST(loser_new_elo, loser_tier_min_elo);
    END IF;

    winner_should_count_streak := should_count_for_streak(
        winner_id_val,
        loser_id_val,
        winner_elo_before,
        loser_elo_before,
        NEW.id
    );

    IF winner_should_count_streak THEN
        winner_new_streak := winner_current_streak + 1;
    ELSE
        winner_new_streak := winner_current_streak;
    END IF;

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

    UPDATE users SET 
        battle_elo_rating = battle_elo_rating + elo_change,
        battle_wins = COALESCE(battle_wins, 0) + 1,
        current_win_streak = winner_new_streak,
        season_best_win_streak = GREATEST(COALESCE(season_best_win_streak, 0), winner_new_streak),
        battle_streak = CASE 
            WHEN battle_streak < 0 THEN winner_new_streak 
            ELSE winner_new_streak 
        END,
        last_battle_match_at = NOW()
    WHERE id = winner_id_val;

    IF winner_should_count_streak AND winner_new_streak IN (3, 5, 7, 10) THEN
        SELECT check_and_award_streak_rewards(winner_id_val, winner_new_streak) INTO reward_result;
    END IF;

    UPDATE users SET 
        battle_elo_rating = loser_new_elo,
        battle_losses = COALESCE(battle_losses, 0) + 1,
        current_win_streak = 0,
        battle_streak = CASE 
            WHEN battle_streak > 0 THEN -1 
            ELSE battle_streak - 1 
        END,
        last_battle_match_at = NOW()
    WHERE id = loser_id_val;

    -- Positions updated by frontend calling update_battle_positions() after success (avoids timeout)
    -- PERFORM update_battle_positions();  -- REMOVED

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
'Updates Elo after battle room completion. Tier protection, streak, rewards. Position update is done by frontend in background.';
