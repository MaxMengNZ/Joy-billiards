-- ============================================
-- Implement Streak Rewards System
-- 实现连胜奖励系统
-- ============================================
-- This migration implements the Battle Streak Rewards System:
-- 此迁移实现 Battle 连胜奖励系统：
-- - 3连胜: +5 Battle Tokens
-- - 5连胜: +10 Battle Tokens
-- - 7连胜: +15 Battle Tokens + 24h 称号
-- - 10连胜: +25 Battle Tokens + 公告
-- - 每赛季每个阈值只领一次
-- ============================================

-- ============================================
-- Add Battle Tokens field to users table
-- ============================================
ALTER TABLE users
ADD COLUMN IF NOT EXISTS battle_tokens INTEGER DEFAULT 0;

COMMENT ON COLUMN users.battle_tokens IS 'Battle Tokens earned from streak rewards and other Battle activities';

-- ============================================
-- TABLE: battle_streak_rewards (奖励历史记录)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_streak_rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    streak_threshold INTEGER NOT NULL CHECK (streak_threshold IN (3, 5, 7, 10)),
    tokens_awarded INTEGER NOT NULL,
    title_awarded BOOLEAN DEFAULT FALSE,
    announcement_made BOOLEAN DEFAULT FALSE,
    season_year INTEGER NOT NULL, -- Current season year (e.g., 2026)
    season_month INTEGER NOT NULL CHECK (season_month >= 1 AND season_month <= 12), -- Current season month
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one reward per threshold per season per user
    UNIQUE(user_id, streak_threshold, season_year, season_month)
);

CREATE INDEX IF NOT EXISTS idx_battle_streak_rewards_user ON battle_streak_rewards(user_id);
CREATE INDEX IF NOT EXISTS idx_battle_streak_rewards_season ON battle_streak_rewards(season_year, season_month);
CREATE INDEX IF NOT EXISTS idx_battle_streak_rewards_awarded_at ON battle_streak_rewards(awarded_at DESC);

COMMENT ON TABLE battle_streak_rewards IS 'Records of streak rewards awarded to players. Each threshold (3/5/7/10) can only be claimed once per season per user.';

-- ============================================
-- TABLE: battle_titles (称号系统)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_titles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title_name VARCHAR(100) NOT NULL, -- e.g., "7-Win Streak Champion"
    title_icon VARCHAR(10), -- e.g., "🔥🔥🔥"
    expires_at TIMESTAMP WITH TIME ZONE, -- NULL for permanent titles
    is_active BOOLEAN DEFAULT TRUE,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_battle_titles_user ON battle_titles(user_id);
CREATE INDEX IF NOT EXISTS idx_battle_titles_active ON battle_titles(user_id, is_active) WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS idx_battle_titles_expires ON battle_titles(expires_at) WHERE expires_at IS NOT NULL;

COMMENT ON TABLE battle_titles IS 'Battle titles/achievements earned by players. Can be temporary (24h) or permanent.';

-- ============================================
-- TABLE: battle_announcements (公告系统)
-- ============================================
CREATE TABLE IF NOT EXISTS battle_announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    announcement_type VARCHAR(50) NOT NULL DEFAULT 'streak_10', -- e.g., 'streak_10', 'milestone', etc.
    message TEXT NOT NULL, -- e.g., "Kieran Dempsey achieved a 10-win streak!"
    is_featured BOOLEAN DEFAULT FALSE, -- Show prominently on homepage
    expires_at TIMESTAMP WITH TIME ZONE, -- NULL for permanent announcements
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_battle_announcements_user ON battle_announcements(user_id);
CREATE INDEX IF NOT EXISTS idx_battle_announcements_featured ON battle_announcements(is_featured, created_at DESC) WHERE is_featured = TRUE;
CREATE INDEX IF NOT EXISTS idx_battle_announcements_expires ON battle_announcements(expires_at) WHERE expires_at IS NOT NULL;

COMMENT ON TABLE battle_announcements IS 'Battle system announcements (e.g., 10-win streak achievements). Can be featured on homepage.';

-- ============================================
-- Function: Get current season (year and month)
-- ============================================
CREATE OR REPLACE FUNCTION get_current_season()
RETURNS TABLE(season_year INTEGER, season_month INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        EXTRACT(YEAR FROM NOW())::INTEGER AS season_year,
        EXTRACT(MONTH FROM NOW())::INTEGER AS season_month;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_current_season() IS 'Returns current season year and month for streak reward tracking';

-- ============================================
-- Function: Check and award streak rewards
-- ============================================
CREATE OR REPLACE FUNCTION check_and_award_streak_rewards(
    p_user_id UUID,
    p_current_streak INTEGER
)
RETURNS JSONB AS $$
DECLARE
    v_season_year INTEGER;
    v_season_month INTEGER;
    v_reward_config JSONB;
    v_tokens_awarded INTEGER := 0;
    v_title_awarded BOOLEAN := FALSE;
    v_announcement_made BOOLEAN := FALSE;
    v_reward_data JSONB;
    v_already_claimed BOOLEAN;
    v_user_name VARCHAR;
BEGIN
    -- Only process if streak is 3, 5, 7, or 10 (and not already claimed)
    IF p_current_streak NOT IN (3, 5, 7, 10) THEN
        RETURN jsonb_build_object('awarded', false, 'reason', 'streak_threshold_not_met');
    END IF;
    
    -- Get current season
    SELECT season_year, season_month INTO v_season_year, v_season_month
    FROM get_current_season();
    
    -- Check if this threshold has already been claimed this season
    SELECT EXISTS(
        SELECT 1 FROM battle_streak_rewards
        WHERE user_id = p_user_id
          AND streak_threshold = p_current_streak
          AND season_year = v_season_year
          AND season_month = v_season_month
    ) INTO v_already_claimed;
    
    IF v_already_claimed THEN
        RETURN jsonb_build_object('awarded', false, 'reason', 'already_claimed_this_season');
    END IF;
    
    -- Get user name for announcements
    SELECT name INTO v_user_name FROM users WHERE id = p_user_id;
    
    -- Determine reward based on streak threshold
    CASE p_current_streak
        WHEN 3 THEN
            v_tokens_awarded := 5;
            v_reward_config := jsonb_build_object(
                'tokens', 5,
                'title', false,
                'announcement', false
            );
        WHEN 5 THEN
            v_tokens_awarded := 10;
            v_reward_config := jsonb_build_object(
                'tokens', 10,
                'title', false,
                'announcement', false
            );
        WHEN 7 THEN
            v_tokens_awarded := 15;
            v_title_awarded := TRUE;
            v_reward_config := jsonb_build_object(
                'tokens', 15,
                'title', true,
                'title_name', '7-Win Streak Champion',
                'title_icon', '🔥🔥🔥',
                'title_duration_hours', 24,
                'announcement', false
            );
        WHEN 10 THEN
            v_tokens_awarded := 25;
            v_announcement_made := TRUE;
            v_reward_config := jsonb_build_object(
                'tokens', 25,
                'title', false,
                'announcement', true,
                'announcement_message', v_user_name || ' achieved a legendary 10-win streak!',
                'announcement_type', 'streak_10'
            );
        ELSE
            RETURN jsonb_build_object('awarded', false, 'reason', 'invalid_threshold');
    END CASE;
    
    -- Award tokens
    UPDATE users
    SET battle_tokens = COALESCE(battle_tokens, 0) + v_tokens_awarded
    WHERE id = p_user_id;
    
    -- Record reward
    INSERT INTO battle_streak_rewards (
        user_id,
        streak_threshold,
        tokens_awarded,
        title_awarded,
        announcement_made,
        season_year,
        season_month
    ) VALUES (
        p_user_id,
        p_current_streak,
        v_tokens_awarded,
        v_title_awarded,
        v_announcement_made,
        v_season_year,
        v_season_month
    );
    
    -- Award title if applicable (7-win streak)
    IF v_title_awarded THEN
        INSERT INTO battle_titles (
            user_id,
            title_name,
            title_icon,
            expires_at
        ) VALUES (
            p_user_id,
            v_reward_config->>'title_name',
            v_reward_config->>'title_icon',
            NOW() + (v_reward_config->>'title_duration_hours')::INTEGER * INTERVAL '1 hour'
        );
    END IF;
    
    -- Create announcement if applicable (10-win streak)
    IF v_announcement_made THEN
        INSERT INTO battle_announcements (
            user_id,
            announcement_type,
            message,
            is_featured,
            expires_at
        ) VALUES (
            p_user_id,
            v_reward_config->>'announcement_type',
            v_reward_config->>'announcement_message',
            TRUE, -- Featured on homepage
            NOW() + INTERVAL '7 days' -- Show for 7 days
        );
    END IF;
    
    -- Build return data
    v_reward_data := jsonb_build_object(
        'awarded', true,
        'streak_threshold', p_current_streak,
        'tokens_awarded', v_tokens_awarded,
        'title_awarded', v_title_awarded,
        'announcement_made', v_announcement_made,
        'season_year', v_season_year,
        'season_month', v_season_month
    );
    
    RETURN v_reward_data;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_and_award_streak_rewards IS 'Checks if player has reached a streak threshold (3/5/7/10) and awards rewards if not already claimed this season. Returns JSONB with reward details.';

-- ============================================
-- Update Elo trigger to call reward function
-- ============================================
-- Note: We'll update the existing trigger function to call the reward function
-- This will be done in a separate step to avoid conflicts

-- ============================================
-- Initialize existing users' battle_tokens to 0 if NULL
-- ============================================
UPDATE users
SET battle_tokens = 0
WHERE battle_tokens IS NULL;

-- ============================================
-- Comments
-- ============================================
COMMENT ON TABLE users IS 'Users table now includes battle_tokens for Battle system rewards.';
