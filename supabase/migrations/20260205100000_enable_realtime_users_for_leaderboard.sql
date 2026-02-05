-- ============================================
-- Enable Realtime for users table (Battle Leaderboard)
-- 为 users 表启用 Realtime，使排行榜在 Elo/胜负更新后即时刷新
-- ============================================
-- When a battle match completes, the trigger updates users (battle_elo_rating, battle_wins, etc.).
-- Adding users to the realtime publication lets the leaderboard page receive those updates
-- and refresh the list without the user manually reloading.
-- ============================================

-- Only add if not already in publication (avoid error on re-run)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'users'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE users;
  END IF;
END $$;

COMMENT ON TABLE users IS 'Users table: Realtime enabled for battle leaderboard live updates (Elo, wins, losses, tier).';
