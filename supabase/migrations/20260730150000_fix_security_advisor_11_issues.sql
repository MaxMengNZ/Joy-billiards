-- Fix the 11 current Supabase Security Advisor errors without changing the
-- public leaderboard contract used by the website.

BEGIN;

-- Public profile views must obey the querying role's RLS and privileges.
ALTER VIEW public.user_stats_view SET (security_invoker = true);
ALTER VIEW public.point_history SET (security_invoker = true);
ALTER VIEW public.leaderboard_view SET (security_invoker = true);
ALTER VIEW public.pro_leaderboard SET (security_invoker = true);
ALTER VIEW public.student_leaderboard SET (security_invoker = true);
ALTER VIEW public.public_users SET (security_invoker = true);
ALTER VIEW public.battle_opponent_search SET (security_invoker = true);

-- Views should only be readable. They previously inherited broad privileges.
REVOKE ALL ON
  public.user_stats_view,
  public.point_history,
  public.leaderboard_view,
  public.pro_leaderboard,
  public.student_leaderboard,
  public.public_users,
  public.battle_opponent_search
FROM anon, authenticated;

GRANT SELECT ON
  public.user_stats_view,
  public.point_history,
  public.leaderboard_view,
  public.pro_leaderboard,
  public.student_leaderboard,
  public.public_users
TO anon, authenticated;

-- Battle opponent search contains email addresses, so it is never anonymous.
GRANT SELECT ON public.battle_opponent_search TO authenticated;

-- Keep the existing public leaderboard working through SECURITY INVOKER views
-- while exposing only the exact non-sensitive columns those views require.
GRANT SELECT (
  id,
  name,
  ranking_level,
  ranking_points,
  pro_ranking_points,
  student_ranking_points,
  wins,
  losses,
  break_and_run_count,
  skill_level,
  is_active,
  last_match_date,
  created_at,
  pro_wins,
  pro_losses,
  pro_break_and_run_count,
  student_wins,
  student_losses,
  student_break_and_run_count
) ON public.users TO anon;

DROP POLICY IF EXISTS "Public can view active public player profiles"
  ON public.users;
CREATE POLICY "Public can view active public player profiles"
  ON public.users
  FOR SELECT
  TO anon
  USING (is_active = true);

-- Static battle tier configuration remains publicly readable, but not writable.
ALTER TABLE public.battle_tier_config ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.battle_tier_config FROM anon, authenticated;
GRANT SELECT ON public.battle_tier_config TO anon, authenticated;
DROP POLICY IF EXISTS "Public can view battle tier configuration"
  ON public.battle_tier_config;
CREATE POLICY "Public can view battle tier configuration"
  ON public.battle_tier_config
  FOR SELECT
  TO anon, authenticated
  USING (true);

-- Streak rewards and titles are private to the signed-in player.
ALTER TABLE public.battle_streak_rewards ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.battle_streak_rewards FROM anon, authenticated;
GRANT SELECT ON public.battle_streak_rewards TO authenticated;
DROP POLICY IF EXISTS "Players can view own battle streak rewards"
  ON public.battle_streak_rewards;
CREATE POLICY "Players can view own battle streak rewards"
  ON public.battle_streak_rewards
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.users
      WHERE users.id = battle_streak_rewards.user_id
        AND users.auth_id = (SELECT auth.uid())
    )
  );

ALTER TABLE public.battle_titles ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.battle_titles FROM anon, authenticated;
GRANT SELECT ON public.battle_titles TO authenticated;
DROP POLICY IF EXISTS "Players can view own battle titles"
  ON public.battle_titles;
CREATE POLICY "Players can view own battle titles"
  ON public.battle_titles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.users
      WHERE users.id = battle_titles.user_id
        AND users.auth_id = (SELECT auth.uid())
    )
  );

-- Announcements contain only display copy and remain publicly readable.
ALTER TABLE public.battle_announcements ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.battle_announcements FROM anon, authenticated;
GRANT SELECT ON public.battle_announcements TO anon, authenticated;
DROP POLICY IF EXISTS "Public can view current battle announcements"
  ON public.battle_announcements;
CREATE POLICY "Public can view current battle announcements"
  ON public.battle_announcements
  FOR SELECT
  TO anon, authenticated
  USING (expires_at IS NULL OR expires_at > now());

COMMIT;
