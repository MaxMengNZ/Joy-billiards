-- ============================================
-- Battle Tier Rebalancing - 段位系统重新平衡
-- ============================================
-- This migration rebalances the tier system to make progression more reasonable
-- 重新平衡段位系统，使升级更合理
-- ============================================
-- Target: Each sub-tier (III, II, I) requires ~5-10 wins to advance
-- 目标：每个小段位（III, II, I）需要约5-10场胜利才能升级
-- ============================================

-- Update tier configurations with more reasonable Elo ranges
-- 更新段位配置，使用更合理的Elo范围

UPDATE battle_tier_config SET
    elo_min = CASE tier_name_en
        -- Bronze (1000-1300, 100 Elo per sub-tier)
        WHEN 'bronze_iii' THEN 1000
        WHEN 'bronze_ii' THEN 1100
        WHEN 'bronze_i' THEN 1200
        -- Silver (1300-1600, 100 Elo per sub-tier)
        WHEN 'silver_iii' THEN 1300
        WHEN 'silver_ii' THEN 1400
        WHEN 'silver_i' THEN 1500
        -- Gold (1600-1900, 100 Elo per sub-tier)
        WHEN 'gold_iv' THEN 1600
        WHEN 'gold_iii' THEN 1700
        WHEN 'gold_ii' THEN 1800
        WHEN 'gold_i' THEN 1900
        -- Platinum (1900-2200, 100 Elo per sub-tier)
        WHEN 'platinum_iv' THEN 1900
        WHEN 'platinum_iii' THEN 2000
        WHEN 'platinum_ii' THEN 2100
        WHEN 'platinum_i' THEN 2200
        -- Diamond (2200-2600, 80-100 Elo per sub-tier)
        WHEN 'diamond_v' THEN 2200
        WHEN 'diamond_iv' THEN 2300
        WHEN 'diamond_iii' THEN 2400
        WHEN 'diamond_ii' THEN 2500
        WHEN 'diamond_i' THEN 2600
        -- Master (2600-3000, 80 Elo per sub-tier)
        WHEN 'star_glory_v' THEN 2600
        WHEN 'star_glory_iv' THEN 2680
        WHEN 'star_glory_iii' THEN 2760
        WHEN 'star_glory_ii' THEN 2840
        WHEN 'star_glory_i' THEN 2920
        -- King Tiers (3000+)
        WHEN 'king_strongest' THEN 3000
        WHEN 'king_peerless' THEN 3200
        WHEN 'king_glory' THEN 3400
        WHEN 'king_legendary' THEN 3600
        ELSE elo_min
    END,
    elo_max = CASE tier_name_en
        -- Bronze
        WHEN 'bronze_iii' THEN 1100
        WHEN 'bronze_ii' THEN 1200
        WHEN 'bronze_i' THEN 1300
        -- Silver
        WHEN 'silver_iii' THEN 1400
        WHEN 'silver_ii' THEN 1500
        WHEN 'silver_i' THEN 1600
        -- Gold
        WHEN 'gold_iv' THEN 1700
        WHEN 'gold_iii' THEN 1800
        WHEN 'gold_ii' THEN 1900
        WHEN 'gold_i' THEN 2000
        -- Platinum
        WHEN 'platinum_iv' THEN 2000
        WHEN 'platinum_iii' THEN 2100
        WHEN 'platinum_ii' THEN 2200
        WHEN 'platinum_i' THEN 2300
        -- Diamond
        WHEN 'diamond_v' THEN 2300
        WHEN 'diamond_iv' THEN 2400
        WHEN 'diamond_iii' THEN 2500
        WHEN 'diamond_ii' THEN 2600
        WHEN 'diamond_i' THEN 2700
        -- Master
        WHEN 'star_glory_v' THEN 2680
        WHEN 'star_glory_iv' THEN 2760
        WHEN 'star_glory_iii' THEN 2840
        WHEN 'star_glory_ii' THEN 2920
        WHEN 'star_glory_i' THEN 3000
        -- King Tiers
        WHEN 'king_strongest' THEN 3200
        WHEN 'king_peerless' THEN 3400
        WHEN 'king_glory' THEN 3600
        WHEN 'king_legendary' THEN 9999
        ELSE elo_max
    END
WHERE tier_name_en IN (
    'bronze_iii', 'bronze_ii', 'bronze_i',
    'silver_iii', 'silver_ii', 'silver_i',
    'gold_iv', 'gold_iii', 'gold_ii', 'gold_i',
    'platinum_iv', 'platinum_iii', 'platinum_ii', 'platinum_i',
    'diamond_v', 'diamond_iv', 'diamond_iii', 'diamond_ii', 'diamond_i',
    'star_glory_v', 'star_glory_iv', 'star_glory_iii', 'star_glory_ii', 'star_glory_i',
    'king_strongest', 'king_peerless', 'king_glory', 'king_legendary'
);

-- Update all users' tier and stars based on new ranges
-- 根据新范围更新所有用户的段位和星数
UPDATE users
SET 
    battle_tier = get_battle_tier_from_elo(battle_elo_rating),
    battle_stars = calculate_battle_stars(battle_elo_rating, get_battle_tier_from_elo(battle_elo_rating))
WHERE battle_elo_rating IS NOT NULL;

-- Update battle positions
SELECT update_battle_positions();

COMMENT ON TABLE battle_tier_config IS 'Battle tier configuration - REBALANCED: Each sub-tier requires ~5-10 wins to advance';
