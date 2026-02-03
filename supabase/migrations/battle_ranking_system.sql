-- ============================================
-- Battle Ranking System - 独立的Battle段位排行系统
-- ============================================
-- This migration creates a complete Battle ranking system
-- Based on Elo rating with tier/star system (similar to mobile games)
-- 基于Elo评分的段位/星数系统（类似手游）
-- ============================================

-- ============================================
-- EXTEND users TABLE - Add Battle Ranking Fields
-- ============================================
-- Add unified Battle Elo (no pro/student division)
ALTER TABLE users
ADD COLUMN IF NOT EXISTS battle_elo_rating INTEGER DEFAULT 1000, -- Unified Battle Elo (not pro/student)
ADD COLUMN IF NOT EXISTS battle_tier VARCHAR(50) DEFAULT 'bronze_iii', -- Current tier (e.g., 'bronze_iii', 'gold_i')
ADD COLUMN IF NOT EXISTS battle_stars INTEGER DEFAULT 0, -- Current stars in tier (0-3 typically)
ADD COLUMN IF NOT EXISTS battle_wins INTEGER DEFAULT 0, -- Total Battle wins
ADD COLUMN IF NOT EXISTS battle_losses INTEGER DEFAULT 0, -- Total Battle losses
ADD COLUMN IF NOT EXISTS battle_position INTEGER, -- Global Battle position/rank
ADD COLUMN IF NOT EXISTS battle_streak INTEGER DEFAULT 0, -- Win/loss streak
ADD COLUMN IF NOT EXISTS last_battle_match_at TIMESTAMP WITH TIME ZONE;

-- ============================================
-- TABLE: battle_tier_config (段位配置表)
-- ============================================
-- Defines all tiers, their Elo ranges, star requirements, etc.
CREATE TABLE IF NOT EXISTS battle_tier_config (
    id SERIAL PRIMARY KEY,
    tier_name_en VARCHAR(50) NOT NULL UNIQUE, -- e.g., 'bronze_iii', 'gold_i'
    tier_name_cn VARCHAR(50) NOT NULL, -- e.g., '沉稳青铜 III'
    tier_group INTEGER NOT NULL, -- Major tier group (1-10: Bronze to Legendary King)
    tier_sub_level INTEGER NOT NULL, -- Sub-level within group (1-5 typically)
    elo_min INTEGER NOT NULL, -- Minimum Elo for this tier
    elo_max INTEGER NOT NULL, -- Maximum Elo for this tier
    stars_required INTEGER DEFAULT 3, -- Stars needed to advance (typically 3)
    star_protection BOOLEAN DEFAULT false, -- Low tier protection (no star loss on defeat)
    point_coefficient NUMERIC(5,2), -- Point coefficient for calculations
    national_tier VARCHAR(20), -- National tier equivalent (e.g., '1档', '5档+')
    rank_inheritance VARCHAR(50), -- Next rank when advancing
    display_order INTEGER NOT NULL, -- Order for display
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert tier configurations based on the image
-- 根据图片插入段位配置
INSERT INTO battle_tier_config (tier_name_en, tier_name_cn, tier_group, tier_sub_level, elo_min, elo_max, stars_required, star_protection, point_coefficient, national_tier, rank_inheritance, display_order) VALUES
-- Three Stars Group (三颗星)
('bronze_iii', 'Bronze III', 1, 3, 1000, 2450, 3, true, 11.9, '1档-', 'bronze_ii', 1),
('bronze_ii', 'Bronze II', 1, 2, 2450, 2550, 3, true, 11.7, '1档', 'bronze_i', 2),
('bronze_i', 'Bronze I', 1, 1, 2550, 2650, 3, true, 11.5, '1档+', 'silver_iii', 3),
('silver_iii', 'Silver III', 2, 3, 2650, 2750, 3, true, 11.3, '2档-', 'silver_ii', 4),
('silver_ii', 'Silver II', 2, 2, 2750, 2850, 3, true, 11.1, '2档', 'silver_i', 5),
('silver_i', 'Silver I', 2, 1, 2850, 2950, 3, true, 10.9, '2档+', 'gold_iv', 6),

-- Four Stars Group (四颗星)
('gold_iv', 'Gold IV', 3, 4, 2950, 3050, 3, true, 10.7, '3档-', 'gold_iii', 7),
('gold_iii', 'Gold III', 3, 3, 3050, 3150, 3, false, 10.5, '3档', 'gold_ii', 8),
('gold_ii', 'Gold II', 3, 2, 3150, 3250, 3, false, 10.3, '3档+', 'gold_i', 9),
('gold_i', 'Gold I', 3, 1, 3250, 3350, 3, false, 10.1, '4档-', 'platinum_iv', 10),
('platinum_iv', 'Platinum IV', 4, 4, 3350, 3450, 3, false, 9.9, '4档', 'platinum_iii', 11),
('platinum_iii', 'Platinum III', 4, 3, 3450, 3550, 3, false, 9.7, '4档+', 'platinum_ii', 12),
('platinum_ii', 'Platinum II', 4, 2, 3550, 3650, 3, false, 9.5, '5档-', 'platinum_i', 13),
('platinum_i', 'Platinum I', 4, 1, 3650, 3750, 3, false, 9.3, '5档', 'diamond_v', 14),

-- Five Stars Group (五颗星)
('diamond_v', 'Diamond V', 5, 5, 3750, 3850, 3, false, 9.1, '5档+', 'diamond_iv', 15),
('diamond_iv', 'Diamond IV', 5, 4, 3850, 4000, 3, false, 9.0, '5档++', 'diamond_iii', 16),
('diamond_iii', 'Diamond III', 5, 3, 4000, 4200, 3, false, 8.9, '6档--', 'diamond_ii', 17),
('diamond_ii', 'Diamond II', 5, 2, 4200, 4400, 3, false, 8.7, '6档-', 'diamond_i', 18),
('diamond_i', 'Diamond I', 5, 1, 4400, 4600, 3, false, 8.5, '6档', 'star_glory_v', 19),
('star_glory_v', 'Master V', 6, 5, 4600, 4750, 3, false, 8.4, '6档+', 'star_glory_iv', 20),
('star_glory_iv', 'Master IV', 6, 4, 4750, 4900, 3, false, 8.3, '6档++', 'star_glory_iii', 21),
('star_glory_iii', 'Master III', 6, 3, 4900, 5050, 3, false, 8.2, '7档-', 'star_glory_ii', 22),
('star_glory_ii', 'Master II', 6, 2, 5050, 5200, 3, false, 8.15, '7档', 'star_glory_i', 23),
('star_glory_i', 'Master I', 6, 1, 5200, 5350, 3, false, 8.1, '7档+', 'king_strongest', 24),

-- King Tiers (杆王)
('king_strongest', 'Grand Master', 7, 0, 5350, 5725, 0, false, 8.0, '7档', 'diamond_ii', 25),
('king_peerless', 'The King', 8, 0, 5725, 6100, 0, false, 7.9, '8档', 'diamond_i', 26),
('king_glory', 'Legend', 9, 0, 6100, 6500, 0, false, 7.9, '9档', 'star_glory_v', 27),
('king_legendary', 'Hall of Fame', 10, 0, 6500, 9999, 0, false, 7.9, '10档', 'star_glory_iii', 28)
ON CONFLICT (tier_name_en) DO UPDATE SET tier_name_cn = EXCLUDED.tier_name_cn;

-- ============================================
-- FUNCTION: get_battle_tier_from_elo (根据Elo获取段位)
-- ============================================
CREATE OR REPLACE FUNCTION get_battle_tier_from_elo(elo_rating INTEGER)
RETURNS VARCHAR(50) AS $$
DECLARE
    tier_name VARCHAR(50);
BEGIN
    SELECT tier_name_en INTO tier_name
    FROM battle_tier_config
    WHERE elo_rating >= elo_min AND elo_rating < elo_max
    ORDER BY display_order DESC
    LIMIT 1;
    
    -- If no tier found, return lowest tier
    IF tier_name IS NULL THEN
        RETURN 'bronze_iii';
    END IF;
    
    RETURN tier_name;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: calculate_battle_stars (计算星数)
-- ============================================
CREATE OR REPLACE FUNCTION calculate_battle_stars(elo_rating INTEGER, tier_name VARCHAR(50))
RETURNS INTEGER AS $$
DECLARE
    tier_config RECORD;
    stars INTEGER;
    elo_range INTEGER;
    elo_position NUMERIC;
BEGIN
    -- Get tier config
    SELECT * INTO tier_config
    FROM battle_tier_config
    WHERE tier_name_en = tier_name;
    
    IF NOT FOUND THEN
        RETURN 0;
    END IF;
    
    -- King tiers don't use stars
    IF tier_config.tier_group >= 7 THEN
        RETURN 0;
    END IF;
    
    -- Calculate stars based on position within tier
    elo_range := tier_config.elo_max - tier_config.elo_min;
    IF elo_range = 0 THEN
        RETURN tier_config.stars_required;
    END IF;
    
    elo_position := elo_rating - tier_config.elo_min;
    stars := FLOOR((elo_position / elo_range::NUMERIC) * tier_config.stars_required);
    
    -- Ensure stars are within valid range
    IF stars < 0 THEN
        stars := 0;
    ELSIF stars > tier_config.stars_required THEN
        stars := tier_config.stars_required;
    END IF;
    
    RETURN stars;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: update_battle_tier_and_stars (更新段位和星数)
-- ============================================
CREATE OR REPLACE FUNCTION update_battle_tier_and_stars()
RETURNS TRIGGER AS $$
DECLARE
    new_tier VARCHAR(50);
    new_stars INTEGER;
BEGIN
    -- Only update if battle_elo_rating changed
    IF NEW.battle_elo_rating IS NULL OR NEW.battle_elo_rating = OLD.battle_elo_rating THEN
        RETURN NEW;
    END IF;
    
    -- Get tier from Elo
    new_tier := get_battle_tier_from_elo(NEW.battle_elo_rating);
    new_stars := calculate_battle_stars(NEW.battle_elo_rating, new_tier);
    
    -- Update tier and stars
    NEW.battle_tier := new_tier;
    NEW.battle_stars := new_stars;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: trigger_update_battle_tier (自动更新段位触发器)
-- ============================================
DROP TRIGGER IF EXISTS trigger_update_battle_tier ON users;
CREATE TRIGGER trigger_update_battle_tier
BEFORE UPDATE OF battle_elo_rating ON users
FOR EACH ROW
EXECUTE FUNCTION update_battle_tier_and_stars();

-- ============================================
-- FUNCTION: update_battle_positions (更新Battle排名)
-- ============================================
CREATE OR REPLACE FUNCTION update_battle_positions()
RETURNS void AS $$
BEGIN
    -- Update global Battle positions based on Elo
    WITH ranked_players AS (
        SELECT
            id,
            ROW_NUMBER() OVER (ORDER BY battle_elo_rating DESC, battle_wins DESC, battle_losses ASC) as position
        FROM users
        WHERE battle_elo_rating > 0
    )
    UPDATE users u
    SET battle_position = r.position
    FROM ranked_players r
    WHERE u.id = r.id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCTION: get_tier_difference (计算段位差)
-- ============================================
-- Used for challenge match star calculations
CREATE OR REPLACE FUNCTION get_tier_difference(tier1 VARCHAR(50), tier2 VARCHAR(50))
RETURNS INTEGER AS $$
DECLARE
    group1 INTEGER;
    group2 INTEGER;
BEGIN
    SELECT tier_group INTO group1 FROM battle_tier_config WHERE tier_name_en = tier1;
    SELECT tier_group INTO group2 FROM battle_tier_config WHERE tier_name_en = tier2;
    
    IF group1 IS NULL OR group2 IS NULL THEN
        RETURN 0;
    END IF;
    
    RETURN ABS(group1 - group2);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE battle_tier_config IS 'Battle tier configuration - defines all ranking tiers, Elo ranges, and star requirements';
COMMENT ON FUNCTION get_battle_tier_from_elo IS 'Returns the tier name based on Elo rating';
COMMENT ON FUNCTION calculate_battle_stars IS 'Calculates the number of stars within a tier based on Elo rating';
COMMENT ON FUNCTION update_battle_tier_and_stars IS 'Automatically updates tier and stars when Elo changes';
COMMENT ON FUNCTION update_battle_positions IS 'Updates global Battle leaderboard positions';
COMMENT ON FUNCTION get_tier_difference IS 'Calculates tier difference for challenge match star adjustments';
