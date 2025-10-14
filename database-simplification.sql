-- ============================================
-- Database Simplification: 5 tables → 3 tables
-- Joy Billiards Tournament System
-- ============================================

-- Step 1: Create new simplified 'users' table
-- Combines players + user_profiles + authentication
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    skill_level VARCHAR(20) CHECK (skill_level IN ('beginner', 'intermediate', 'advanced', 'professional')),
    role VARCHAR(20) DEFAULT 'player' CHECK (role IN ('admin', 'player')),
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Step 2: Migrate existing players data to users table
-- Copy all players (without auth.users link for now)
INSERT INTO users (id, name, email, phone, skill_level, wins, losses, created_at, updated_at)
SELECT 
    gen_random_uuid() as id,  -- Temporary UUID, will be linked to auth later
    name,
    email,
    phone,
    skill_level,
    wins,
    losses,
    created_at,
    updated_at
FROM players
ON CONFLICT (email) DO NOTHING;

-- Step 3: Update foreign key references
-- Update matches table to reference users instead of players
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_player1_id_fkey;
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_player2_id_fkey;
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_winner_id_fkey;

-- For now, we'll handle player references differently
-- We'll store player names or emails in matches instead of strict foreign keys
ALTER TABLE matches ADD COLUMN IF NOT EXISTS player1_name VARCHAR(100);
ALTER TABLE matches ADD COLUMN IF NOT EXISTS player2_name VARCHAR(100);
ALTER TABLE matches ADD COLUMN IF NOT EXISTS winner_name VARCHAR(100);

-- Step 4: Drop tournament_participants table (not needed)
DROP TABLE IF EXISTS tournament_participants CASCADE;

-- Step 5: Clean up old tables
-- Drop old players and user_profiles tables
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Drop old user_role type
DROP TYPE IF EXISTS user_role CASCADE;

-- Step 6: Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_users_skill_level ON users(skill_level);

-- Step 7: Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Step 8: Create RLS policies for users
-- Anyone can view users
CREATE POLICY "Anyone can view users"
    ON users FOR SELECT
    USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Admins can manage all users
CREATE POLICY "Admins can manage users"
    ON users FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Allow user creation during signup
CREATE POLICY "Allow user creation during signup"
    ON users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Step 9: Create trigger for auto-updating updated_at
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_users_updated_at_trigger ON users;
CREATE TRIGGER update_users_updated_at_trigger
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at();

-- Step 10: Create trigger for automatic user profile creation
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.users (id, name, email, role, is_active)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'role', 'player'),
        true
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
EXCEPTION
    WHEN others THEN
        RAISE WARNING 'Error creating user profile: %', SQLERRM;
        RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW 
    EXECUTE FUNCTION create_user_profile();

-- Step 11: Update RLS policies for tournaments
DROP POLICY IF EXISTS "Admins can manage tournaments" ON tournaments;
CREATE POLICY "Admins can manage tournaments"
    ON tournaments FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Step 12: Update RLS policies for matches
DROP POLICY IF EXISTS "Admins can manage matches" ON matches;
CREATE POLICY "Admins can manage matches"
    ON matches FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Step 13: Grant permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- Step 14: Add comments
COMMENT ON TABLE users IS 'Unified users table: authentication + player info';
COMMENT ON COLUMN users.role IS 'User role: admin or player';
COMMENT ON COLUMN users.skill_level IS 'Player skill level for matchmaking';

-- Verification
SELECT 
    'Tables after simplification:' as message,
    COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE';

SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

