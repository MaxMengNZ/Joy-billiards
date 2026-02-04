-- ============================================
-- Add Tier Protection Elo Floor
-- 添加段位保护 Elo 下限
-- ============================================
-- This migration adds Elo floor protection for protected tiers
-- When a player in a protected tier (Bronze III - Gold IV) loses,
-- their Elo will not drop below the tier's minimum Elo value
-- 此迁移为受保护段位添加 Elo 下限保护
-- 当受保护段位（Bronze III - Gold IV）的玩家失败时，
-- 他们的 Elo 不会低于段位的最低值
-- ============================================

-- ============================================
-- Update Elo calculation function with tier protection
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
    SELECT battle_elo_rating, battle_tier INTO winner_elo_before, winner_tier_before
    FROM users WHERE id = winner_id_val;
    
    SELECT battle_elo_rating, battle_tier INTO loser_elo_before, loser_tier_before
    FROM users WHERE id = loser_id_val;
    
    -- Default to 1000 if null
    winner_elo_before := COALESCE(winner_elo_before, 1000);
    loser_elo_before := COALESCE(loser_elo_before, 1000);
    
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
        battle_streak = CASE 
            WHEN battle_streak < 0 THEN 1 
            ELSE battle_streak + 1 
        END,
        last_battle_match_at = NOW()
    WHERE id = winner_id_val;
    
    -- Update loser's unified Battle Elo and stats (with tier protection)
    UPDATE users SET 
        battle_elo_rating = loser_new_elo, -- Use protected Elo value
        battle_losses = COALESCE(battle_losses, 0) + 1,
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

-- ============================================
-- Fix XiangRong Li's Elo (should be 1000, not 985)
-- ============================================
UPDATE users
SET battle_elo_rating = 1000
WHERE name = 'XiangRong Li' 
  AND battle_elo_rating < 1000
  AND battle_tier = 'bronze_iii';

-- Recalculate tier and stars for XiangRong
UPDATE users
SET 
    battle_tier = get_battle_tier_from_elo(battle_elo_rating),
    battle_stars = calculate_battle_stars(battle_elo_rating, get_battle_tier_from_elo(battle_elo_rating))
WHERE name = 'XiangRong Li';

-- Update battle positions
SELECT update_battle_positions();

-- ============================================
-- Comments
-- ============================================
COMMENT ON FUNCTION update_elo_after_battle_room_complete() IS 
'Updates Elo ratings after battle room completion. Implements tier protection: players in protected tiers (Bronze III - Gold IV) cannot drop below their tier minimum Elo when losing.';
