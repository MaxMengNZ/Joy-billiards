run-- ============================================
-- Joy Billiards Tournament System - Database Schema
-- ============================================
-- Execute this SQL in your Supabase SQL Editor
-- Dashboard: https://qnwtqgdbgyqwpsdqvxfl.supabase.co

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE: players (玩家表)
-- ============================================
CREATE TABLE IF NOT EXISTS players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    skill_level VARCHAR(20) CHECK (skill_level IN ('beginner', 'intermediate', 'advanced', 'professional')),
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: tournaments (比赛表)
-- ============================================
CREATE TABLE IF NOT EXISTS tournaments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    tournament_type VARCHAR(50) CHECK (tournament_type IN ('single_elimination', 'double_elimination', 'round_robin', 'swiss')),
    start_date TIMESTAMP WITH TIME ZONE NOT NULL,
    end_date TIMESTAMP WITH TIME ZONE,
    max_players INTEGER,
    entry_fee DECIMAL(10, 2) DEFAULT 0,
    prize_pool DECIMAL(10, 2) DEFAULT 0,
    status VARCHAR(20) CHECK (status IN ('upcoming', 'registration', 'in_progress', 'completed', 'cancelled')) DEFAULT 'upcoming',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE: tournament_participants (玩家参赛表)
-- ============================================
CREATE TABLE IF NOT EXISTS tournament_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    player_id UUID NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    seed_number INTEGER,
    final_position INTEGER,
    prize_amount DECIMAL(10, 2) DEFAULT 0,
    UNIQUE(tournament_id, player_id)
);

-- ============================================
-- TABLE: matches (对战记录表)
-- ============================================
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tournament_id UUID NOT NULL REFERENCES tournaments(id) ON DELETE CASCADE,
    player1_id UUID NOT NULL REFERENCES players(id),
    player2_id UUID NOT NULL REFERENCES players(id),
    winner_id UUID REFERENCES players(id),
    round_number INTEGER NOT NULL,
    match_number INTEGER NOT NULL,
    player1_score INTEGER DEFAULT 0,
    player2_score INTEGER DEFAULT 0,
    scheduled_time TIMESTAMP WITH TIME ZONE,
    completed_time TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')) DEFAULT 'scheduled',
    table_number INTEGER,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES for better performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_players_email ON players(email);
CREATE INDEX IF NOT EXISTS idx_tournaments_status ON tournaments(status);
CREATE INDEX IF NOT EXISTS idx_tournaments_start_date ON tournaments(start_date);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_tournament ON tournament_participants(tournament_id);
CREATE INDEX IF NOT EXISTS idx_tournament_participants_player ON tournament_participants(player_id);
CREATE INDEX IF NOT EXISTS idx_matches_tournament ON matches(tournament_id);
CREATE INDEX IF NOT EXISTS idx_matches_players ON matches(player1_id, player2_id);
CREATE INDEX IF NOT EXISTS idx_matches_winner ON matches(winner_id);

-- ============================================
-- TRIGGER: Auto-update updated_at timestamp
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tournaments_updated_at BEFORE UPDATE ON tournaments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;
ALTER TABLE tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Public read access policies
CREATE POLICY "Allow public read access to players" ON players 
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to tournaments" ON tournaments 
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to tournament_participants" ON tournament_participants 
    FOR SELECT USING (true);

CREATE POLICY "Allow public read access to matches" ON matches 
    FOR SELECT USING (true);

-- Allow all operations (for development - modify for production)
CREATE POLICY "Allow all operations on players" ON players 
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on tournaments" ON tournaments 
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on tournament_participants" ON tournament_participants 
    FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on matches" ON matches 
    FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================
-- Insert sample players
INSERT INTO players (name, email, phone, skill_level) VALUES
('John Smith', 'john.smith@example.com', '021-1234567', 'advanced'),
('Sarah Johnson', 'sarah.j@example.com', '021-2345678', 'intermediate'),
('Michael Chen', 'michael.chen@example.com', '021-3456789', 'professional'),
('Emma Wilson', 'emma.w@example.com', '021-4567890', 'beginner')
ON CONFLICT (email) DO NOTHING;

-- Insert sample tournament
INSERT INTO tournaments (name, description, tournament_type, start_date, max_players, entry_fee, prize_pool, status) VALUES
('Joy Billiards Weekly Championship', 'Weekly championship tournament for all skill levels', 'single_elimination', CURRENT_TIMESTAMP + INTERVAL '7 days', 16, 20.00, 300.00, 'registration')
ON CONFLICT DO NOTHING;

-- ============================================
-- VIEWS for convenient queries
-- ============================================

-- Player statistics view
CREATE OR REPLACE VIEW player_statistics AS
SELECT 
    p.id,
    p.name,
    p.skill_level,
    p.wins,
    p.losses,
    CASE 
        WHEN (p.wins + p.losses) > 0 
        THEN ROUND((p.wins::DECIMAL / (p.wins + p.losses)) * 100, 2)
        ELSE 0 
    END as win_rate,
    COUNT(DISTINCT tp.tournament_id) as tournaments_played
FROM players p
LEFT JOIN tournament_participants tp ON p.id = tp.player_id
GROUP BY p.id, p.name, p.skill_level, p.wins, p.losses;

-- Tournament details view
CREATE OR REPLACE VIEW tournament_details AS
SELECT 
    t.id,
    t.name,
    t.tournament_type,
    t.start_date,
    t.end_date,
    t.status,
    t.max_players,
    t.entry_fee,
    t.prize_pool,
    COUNT(DISTINCT tp.player_id) as registered_players,
    COUNT(DISTINCT m.id) as total_matches,
    COUNT(DISTINCT CASE WHEN m.status = 'completed' THEN m.id END) as completed_matches
FROM tournaments t
LEFT JOIN tournament_participants tp ON t.id = tp.tournament_id
LEFT JOIN matches m ON t.id = m.tournament_id
GROUP BY t.id, t.name, t.tournament_type, t.start_date, t.end_date, t.status, t.max_players, t.entry_fee, t.prize_pool;

COMMENT ON TABLE players IS 'Players registered in the tournament system';
COMMENT ON TABLE tournaments IS 'Tournament events';
COMMENT ON TABLE tournament_participants IS 'Players participating in specific tournaments';
COMMENT ON TABLE matches IS 'Match results and schedules';

