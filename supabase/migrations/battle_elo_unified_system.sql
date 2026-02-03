-- ============================================
-- Battle Elo Unified System Migration
-- 统一Battle Elo系统迁移
-- ============================================
-- This migration updates the Battle system to use unified battle_elo_rating
-- and implements matchmaking/challenge match star rules
-- 此迁移更新Battle系统使用统一的battle_elo_rating，并实现匹配赛/挑战赛星数规则
-- ============================================

-- ============================================
-- STEP 1: Initialize existing users' battle_elo_rating
-- ============================================
-- Migrate existing Elo ratings to unified battle_elo_rating
-- Use the higher of pro/student Elo, or default to 1000
UPDATE users
SET battle_elo_rating = GREATEST(
    COALESCE(elo_rating_pro, 1000),
    COALESCE(elo_rating_student, 1000),
    1000
),
battle_wins = COALESCE(battle_wins_pro, 0) + COALESCE(battle_wins_student, 0),
battle_losses = COALESCE(battle_losses_pro, 0) + COALESCE(battle_losses_student, 0)
WHERE battle_elo_rating IS NULL OR battle_elo_rating = 1000;

-- Update tier and stars for all users
UPDATE users
SET 
    battle_tier = get_battle_tier_from_elo(battle_elo_rating),
    battle_stars = calculate_battle_stars(battle_elo_rating, get_battle_tier_from_elo(battle_elo_rating))
WHERE battle_elo_rating IS NOT NULL;

-- ============================================
-- STEP 2: Update battle_rooms table - Remove division requirement
-- ============================================
-- Make division nullable (we don't need it for unified Battle system)
ALTER TABLE battle_rooms
ALTER COLUMN division DROP NOT NULL;

-- ============================================
-- STEP 3: Update Elo calculation function for unified system
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
    star_change INTEGER;
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
    -- Matchmaking: opponents within 1 major tier group
    -- Challenge: opponents beyond 1 major tier group
    SELECT get_tier_difference(winner_tier_before, loser_tier_before) INTO tier_diff;
    is_matchmaking := tier_diff <= 1;
    
    -- Calculate star change based on match type
    IF is_matchmaking THEN
        -- Matchmaking: +1 star for win, -1 star for loss (with protection)
        star_change := 1;
    ELSE
        -- Challenge match: star change = tier difference
        star_change := tier_diff;
    END IF;
    
    -- Store Elo before/after
    NEW.player1_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_elo_before 
        ELSE loser_elo_before 
    END;
    NEW.player1_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player1_id THEN winner_elo_before + elo_change 
        ELSE GREATEST(loser_elo_before - elo_change, 0) 
    END;
    NEW.player2_elo_before := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_elo_before 
        ELSE loser_elo_before 
    END;
    NEW.player2_elo_after := CASE 
        WHEN NEW.winner_id = NEW.player2_id THEN winner_elo_before + elo_change 
        ELSE GREATEST(loser_elo_before - elo_change, 0) 
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
    
    -- Update loser's unified Battle Elo and stats
    -- Check for star protection (Gold IV and below don't lose stars on defeat)
    DECLARE
        loser_tier_config RECORD;
        should_lose_star BOOLEAN;
    BEGIN
        SELECT * INTO loser_tier_config
        FROM battle_tier_config
        WHERE tier_name_en = loser_tier_before;
        
        -- Gold IV and below have star protection
        should_lose_star := COALESCE(loser_tier_config.tier_group, 0) > 3 OR 
                           (loser_tier_config.tier_group = 3 AND loser_tier_config.tier_sub_level < 4);
        
        UPDATE users SET 
            battle_elo_rating = GREATEST(battle_elo_rating - elo_change, 0),
            battle_losses = COALESCE(battle_losses, 0) + 1,
            battle_streak = CASE 
                WHEN battle_streak > 0 THEN -1 
                ELSE battle_streak - 1 
            END,
            last_battle_match_at = NOW()
        WHERE id = loser_id_val;
    END;
    
    -- Update tier and stars automatically via trigger (trigger_update_battle_tier)
    -- Update global positions
    PERFORM update_battle_positions();
    
    -- Insert into battle_match_history (division is now optional/nullable)
    INSERT INTO battle_match_history (
        challenge_id,
        player1_id,
        player2_id,
        winner_id,
        division, -- Can be NULL now
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
        NEW.division, -- May be NULL
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
-- STEP 4: Update battle_match_history to make division nullable
-- ============================================
ALTER TABLE battle_match_history
ALTER COLUMN division DROP NOT NULL;

-- ============================================
-- STEP 5: Add match type tracking to battle_rooms
-- ============================================
ALTER TABLE battle_rooms
ADD COLUMN IF NOT EXISTS match_type VARCHAR(20) DEFAULT 'matchmaking' 
    CHECK (match_type IN ('matchmaking', 'challenge'));

-- Add star change tracking
ALTER TABLE battle_rooms
ADD COLUMN IF NOT EXISTS star_change INTEGER DEFAULT 0;

-- ============================================
-- STEP 6: Function to determine match type based on tier difference
-- ============================================
CREATE OR REPLACE FUNCTION determine_match_type(player1_tier VARCHAR(50), player2_tier VARCHAR(50))
RETURNS VARCHAR(20) AS $$
DECLARE
    tier_diff INTEGER;
BEGIN
    tier_diff := get_tier_difference(player1_tier, player2_tier);
    
    IF tier_diff <= 1 THEN
        RETURN 'matchmaking';
    ELSE
        RETURN 'challenge';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- STEP 7: Update trigger to set match type
-- ============================================
CREATE OR REPLACE FUNCTION set_battle_room_match_type()
RETURNS TRIGGER AS $$
DECLARE
    player1_tier VARCHAR(50);
    player2_tier VARCHAR(50);
BEGIN
    -- Only set when both players are assigned
    IF NEW.player1_id IS NOT NULL AND NEW.player2_id IS NOT NULL THEN
        SELECT battle_tier INTO player1_tier FROM users WHERE id = NEW.player1_id;
        SELECT battle_tier INTO player2_tier FROM users WHERE id = NEW.player2_id;
        
        IF player1_tier IS NOT NULL AND player2_tier IS NOT NULL THEN
            NEW.match_type := determine_match_type(player1_tier, player2_tier);
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_battle_room_match_type ON battle_rooms;
CREATE TRIGGER trigger_set_battle_room_match_type
BEFORE INSERT OR UPDATE OF player1_id, player2_id ON battle_rooms
FOR EACH ROW
EXECUTE FUNCTION set_battle_room_match_type();

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON FUNCTION update_elo_after_battle_room_complete IS 'Updates unified Battle Elo rating and implements matchmaking/challenge match star rules';
COMMENT ON FUNCTION determine_match_type IS 'Determines if a match is matchmaking (within 1 tier) or challenge (beyond 1 tier)';
COMMENT ON COLUMN battle_rooms.match_type IS 'Type of match: matchmaking (within 1 tier) or challenge (beyond 1 tier)';
COMMENT ON COLUMN battle_rooms.star_change IS 'Star change for this match (calculated based on match type and tier difference)';
