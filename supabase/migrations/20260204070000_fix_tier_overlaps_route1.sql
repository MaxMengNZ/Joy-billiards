-- ============================================
-- Fix Tier Overlaps - Route 1 (最小改动版)
-- ============================================
-- 修正段位区间重叠问题，使用路线1：按层级顺延，不允许重叠
-- 保留 100/80/200 宽度理念，但确保段位区间连续无重叠
-- ============================================

-- Update tier configurations to remove overlaps
-- 更新段位配置，消除重叠

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
        -- Gold (1600-2000, 100 Elo per sub-tier)
        WHEN 'gold_iv' THEN 1600
        WHEN 'gold_iii' THEN 1700
        WHEN 'gold_ii' THEN 1800
        WHEN 'gold_i' THEN 1900
        -- Platinum (2000-2400, 100 Elo per sub-tier) - FIXED: Start at 2000, not 1900
        WHEN 'platinum_iv' THEN 2000
        WHEN 'platinum_iii' THEN 2100
        WHEN 'platinum_ii' THEN 2200
        WHEN 'platinum_i' THEN 2300
        -- Diamond (2400-2800, 80 Elo per sub-tier) - FIXED: Start at 2400, not 2200
        WHEN 'diamond_v' THEN 2400
        WHEN 'diamond_iv' THEN 2480
        WHEN 'diamond_iii' THEN 2560
        WHEN 'diamond_ii' THEN 2640
        WHEN 'diamond_i' THEN 2720
        -- Master (2800-3200, 80 Elo per sub-tier) - FIXED: Start at 2800, not 2600
        WHEN 'star_glory_v' THEN 2800
        WHEN 'star_glory_iv' THEN 2880
        WHEN 'star_glory_iii' THEN 2960
        WHEN 'star_glory_ii' THEN 3040
        WHEN 'star_glory_i' THEN 3120
        -- King Tiers (3200+)
        WHEN 'king_strongest' THEN 3200
        WHEN 'king_peerless' THEN 3400
        WHEN 'king_glory' THEN 3600
        WHEN 'king_legendary' THEN 3800
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
        -- Platinum - FIXED: No overlap with Gold I
        WHEN 'platinum_iv' THEN 2100
        WHEN 'platinum_iii' THEN 2200
        WHEN 'platinum_ii' THEN 2300
        WHEN 'platinum_i' THEN 2400
        -- Diamond - FIXED: Start at 2400, no overlap with Platinum
        WHEN 'diamond_v' THEN 2480
        WHEN 'diamond_iv' THEN 2560
        WHEN 'diamond_iii' THEN 2640
        WHEN 'diamond_ii' THEN 2720
        WHEN 'diamond_i' THEN 2800
        -- Master - FIXED: Start at 2800, no overlap with Diamond
        WHEN 'star_glory_v' THEN 2880
        WHEN 'star_glory_iv' THEN 2960
        WHEN 'star_glory_iii' THEN 3040
        WHEN 'star_glory_ii' THEN 3120
        WHEN 'star_glory_i' THEN 3200
        -- King Tiers
        WHEN 'king_strongest' THEN 3400
        WHEN 'king_peerless' THEN 3600
        WHEN 'king_glory' THEN 3800
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

-- Verify no overlaps (self-check query)
-- 验证无重叠（自检查询）
DO $$
DECLARE
    overlap_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO overlap_count
    FROM battle_tier_config t1
    JOIN battle_tier_config t2 ON t1.id < t2.id
    WHERE t1.elo_min < t2.elo_max 
      AND t1.elo_max > t2.elo_min;
    
    IF overlap_count > 0 THEN
        RAISE EXCEPTION '❌ Tier overlap detected! Found % overlapping ranges', overlap_count;
    ELSE
        RAISE NOTICE '✅ No tier overlaps found. All tiers are properly sequenced.';
    END IF;
END $$;

-- Verify all tiers are continuous (no gaps)
-- 验证所有段位连续（无间隙）
DO $$
DECLARE
    gap_count INTEGER;
    expected_min INTEGER := 1000;
    tier_record RECORD;
BEGIN
    FOR tier_record IN 
        SELECT elo_min, elo_max, tier_name_en
        FROM battle_tier_config
        WHERE tier_name_en NOT IN ('king_legendary') -- Hall of Fame has no upper limit
        ORDER BY elo_min
    LOOP
        IF tier_record.elo_min != expected_min THEN
            RAISE EXCEPTION '❌ Gap detected! Expected elo_min = %, but % has elo_min = %', 
                expected_min, tier_record.tier_name_en, tier_record.elo_min;
        END IF;
        expected_min := tier_record.elo_max;
    END LOOP;
    
    RAISE NOTICE '✅ All tiers are continuous. No gaps found.';
END $$;

-- Update all users' tier and stars based on new ranges
-- 根据新范围更新所有用户的段位和星数
UPDATE users
SET 
    battle_tier = get_battle_tier_from_elo(battle_elo_rating),
    battle_stars = calculate_battle_stars(battle_elo_rating, get_battle_tier_from_elo(battle_elo_rating))
WHERE battle_elo_rating IS NOT NULL;

-- Update global positions after tier recalculation
-- 重新计算段位后更新全球排名
SELECT update_battle_positions();

-- ============================================
-- Summary
-- ============================================
-- ✅ Fixed tier overlaps:
--    - Platinum IV: 2000-2100 (was 1900-2000, overlapped with Gold I)
--    - Diamond V: 2400-2480 (was 2200-2280, overlapped with Platinum)
--    - Master V: 2800-2880 (was 2600-2680, overlapped with Diamond I)
--
-- ✅ All tiers now form a continuous sequence:
--    Bronze (1000-1300) → Silver (1300-1600) → Gold (1600-2000) →
--    Platinum (2000-2400) → Diamond (2400-2800) → Master (2800-3200) →
--    Grand Master (3200-3400) → The King (3400-3600) → Legend (3600-3800) →
--    Hall of Fame (3800+)
--
-- ✅ Preserved tier widths:
--    - Bronze/Silver/Gold/Platinum: 100 Elo per sub-tier
--    - Diamond/Master: 80 Elo per sub-tier
--    - Grand Master+: 200 Elo per tier
-- ============================================
