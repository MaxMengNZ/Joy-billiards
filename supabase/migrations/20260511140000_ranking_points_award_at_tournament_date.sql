-- Award ranking points (and year-stats bucket) by tournament/event time in Pacific/Auckland,
-- not by the moment the admin submits. Backdated results then land in the correct month tab.
--
-- Drops prior 4-arg / 8-arg signatures and replaces with extended forms (new trailing params have defaults).

-- ---------------------------------------------------------------------------
-- admin_add_pro_points
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.admin_add_pro_points(uuid, integer, text, uuid);

CREATE OR REPLACE FUNCTION public.admin_add_pro_points(
  p_user_id uuid,
  p_points_change integer,
  p_reason text,
  p_admin_id uuid DEFAULT NULL,
  p_award_at timestamptz DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_ref timestamptz := COALESCE(p_award_at, NOW());
  v_local timestamp WITHOUT TIME ZONE := timezone('Pacific/Auckland'::text, v_ref);
  v_year integer := EXTRACT(YEAR FROM v_local)::integer;
  v_month integer := EXTRACT(MONTH FROM v_local)::integer;
  v_new_total integer;
  v_admin_id uuid := p_admin_id;
BEGIN
  IF v_admin_id IS NULL THEN
    SELECT id INTO v_admin_id
    FROM users
    WHERE auth_id = auth.uid()
    LIMIT 1;
  END IF;

  UPDATE users
  SET pro_ranking_points = pro_ranking_points + p_points_change
  WHERE id = p_user_id
  RETURNING pro_ranking_points INTO v_new_total;

  INSERT INTO ranking_point_history (user_id, points_change, reason, year, month, admin_id, awarded_at)
  VALUES (p_user_id, p_points_change, 'Pro: ' || p_reason, v_year, v_month, v_admin_id, v_ref);

  RETURN json_build_object(
    'success', true,
    'division', 'pro',
    'current_total', v_new_total,
    'points_change', p_points_change,
    'year', v_year,
    'month', v_month
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.admin_add_pro_points(uuid, integer, text, uuid, timestamptz) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_add_pro_points(uuid, integer, text, uuid, timestamptz) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_add_pro_points(uuid, integer, text, uuid, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_add_pro_points(uuid, integer, text, uuid, timestamptz) TO service_role;

-- ---------------------------------------------------------------------------
-- admin_add_student_points
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.admin_add_student_points(uuid, integer, text, uuid);

CREATE OR REPLACE FUNCTION public.admin_add_student_points(
  p_user_id uuid,
  p_points_change integer,
  p_reason text,
  p_admin_id uuid DEFAULT NULL,
  p_award_at timestamptz DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_ref timestamptz := COALESCE(p_award_at, NOW());
  v_local timestamp WITHOUT TIME ZONE := timezone('Pacific/Auckland'::text, v_ref);
  v_year integer := EXTRACT(YEAR FROM v_local)::integer;
  v_month integer := EXTRACT(MONTH FROM v_local)::integer;
  v_new_total integer;
  v_admin_id uuid := p_admin_id;
BEGIN
  IF v_admin_id IS NULL THEN
    SELECT id INTO v_admin_id
    FROM users
    WHERE auth_id = auth.uid()
    LIMIT 1;
  END IF;

  UPDATE users
  SET student_ranking_points = student_ranking_points + p_points_change
  WHERE id = p_user_id
  RETURNING student_ranking_points INTO v_new_total;

  INSERT INTO ranking_point_history (user_id, points_change, reason, year, month, admin_id, awarded_at)
  VALUES (p_user_id, p_points_change, 'Student: ' || p_reason, v_year, v_month, v_admin_id, v_ref);

  RETURN json_build_object(
    'success', true,
    'division', 'student',
    'current_total', v_new_total,
    'points_change', p_points_change,
    'year', v_year,
    'month', v_month
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.admin_add_student_points(uuid, integer, text, uuid, timestamptz) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_add_student_points(uuid, integer, text, uuid, timestamptz) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_add_student_points(uuid, integer, text, uuid, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_add_student_points(uuid, integer, text, uuid, timestamptz) TO service_role;

-- ---------------------------------------------------------------------------
-- admin_update_division_stats — bucket user_year_stats by event year (NZ)
-- ---------------------------------------------------------------------------
DROP FUNCTION IF EXISTS public.admin_update_division_stats(uuid, text, integer, integer, integer, text, uuid, text);

CREATE OR REPLACE FUNCTION public.admin_update_division_stats(
  p_user_id uuid,
  p_division text,
  p_wins integer,
  p_losses integer,
  p_break_and_run integer,
  p_mode text DEFAULT 'increment'::text,
  p_admin_id uuid DEFAULT NULL::uuid,
  p_reason text DEFAULT NULL::text,
  p_award_at timestamptz DEFAULT NULL
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_division text := lower(trim(p_division));
  v_mode text := lower(trim(p_mode));
  v_admin_id uuid := p_admin_id;
  v_user record;
  v_reason text := COALESCE(nullif(trim(p_reason), ''), 'Manual stats update');
  v_old_stats jsonb;
  v_new_stats jsonb;
  v_ref timestamptz := COALESCE(p_award_at, NOW());
  v_local timestamp WITHOUT TIME ZONE := timezone('Pacific/Auckland'::text, v_ref);
  v_current_year integer := EXTRACT(YEAR FROM v_local)::integer;
  v_wins_change integer;
  v_losses_change integer;
  v_break_and_run_change integer;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Access denied';
  END IF;

  IF v_division NOT IN ('pro', 'student') THEN
    RAISE EXCEPTION 'Invalid division %', p_division;
  END IF;

  IF v_mode NOT IN ('increment', 'absolute') THEN
    RAISE EXCEPTION 'Invalid mode %', p_mode;
  END IF;

  SELECT id,
         pro_wins,
         pro_losses,
         pro_break_and_run_count,
         student_wins,
         student_losses,
         student_break_and_run_count
  INTO v_user
  FROM users
  WHERE id = p_user_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  v_old_stats := jsonb_build_object(
    'pro', jsonb_build_object(
      'wins', v_user.pro_wins,
      'losses', v_user.pro_losses,
      'break_and_run', v_user.pro_break_and_run_count
    ),
    'student', jsonb_build_object(
      'wins', v_user.student_wins,
      'losses', v_user.student_losses,
      'break_and_run', v_user.student_break_and_run_count
    )
  );

  IF v_mode = 'increment' THEN
    v_wins_change := COALESCE(p_wins, 0);
    v_losses_change := COALESCE(p_losses, 0);
    v_break_and_run_change := COALESCE(p_break_and_run, 0);

    IF v_division = 'pro' THEN
      v_user.pro_wins := GREATEST(v_user.pro_wins + v_wins_change, 0);
      v_user.pro_losses := GREATEST(v_user.pro_losses + v_losses_change, 0);
      v_user.pro_break_and_run_count := GREATEST(v_user.pro_break_and_run_count + v_break_and_run_change, 0);
    ELSE
      v_user.student_wins := GREATEST(v_user.student_wins + v_wins_change, 0);
      v_user.student_losses := GREATEST(v_user.student_losses + v_losses_change, 0);
      v_user.student_break_and_run_count := GREATEST(v_user.student_break_and_run_count + v_break_and_run_change, 0);
    END IF;
  ELSE
    IF COALESCE(p_wins, 0) < 0 OR COALESCE(p_losses, 0) < 0 OR COALESCE(p_break_and_run, 0) < 0 THEN
      RAISE EXCEPTION 'Statistics cannot be negative';
    END IF;

    IF v_division = 'pro' THEN
      v_wins_change := COALESCE(p_wins, 0) - v_user.pro_wins;
      v_losses_change := COALESCE(p_losses, 0) - v_user.pro_losses;
      v_break_and_run_change := COALESCE(p_break_and_run, 0) - v_user.pro_break_and_run_count;

      v_user.pro_wins := COALESCE(p_wins, 0);
      v_user.pro_losses := COALESCE(p_losses, 0);
      v_user.pro_break_and_run_count := COALESCE(p_break_and_run, 0);
    ELSE
      v_wins_change := COALESCE(p_wins, 0) - v_user.student_wins;
      v_losses_change := COALESCE(p_losses, 0) - v_user.student_losses;
      v_break_and_run_change := COALESCE(p_break_and_run, 0) - v_user.student_break_and_run_count;

      v_user.student_wins := COALESCE(p_wins, 0);
      v_user.student_losses := COALESCE(p_losses, 0);
      v_user.student_break_and_run_count := COALESCE(p_break_and_run, 0);
    END IF;
  END IF;

  IF v_admin_id IS NULL THEN
    SELECT id INTO v_admin_id
    FROM users
    WHERE auth_id = auth.uid()
    LIMIT 1;
  END IF;

  UPDATE users
  SET pro_wins = v_user.pro_wins,
      pro_losses = v_user.pro_losses,
      pro_break_and_run_count = v_user.pro_break_and_run_count,
      student_wins = v_user.student_wins,
      student_losses = v_user.student_losses,
      student_break_and_run_count = v_user.student_break_and_run_count,
      updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO user_year_stats (user_id, division, year, wins, losses, break_and_run_count)
  VALUES (p_user_id, v_division, v_current_year, v_wins_change, v_losses_change, v_break_and_run_change)
  ON CONFLICT (user_id, division, year)
  DO UPDATE SET
    wins = GREATEST(user_year_stats.wins + EXCLUDED.wins, 0),
    losses = GREATEST(user_year_stats.losses + EXCLUDED.losses, 0),
    break_and_run_count = GREATEST(user_year_stats.break_and_run_count + EXCLUDED.break_and_run_count, 0),
    updated_at = NOW();

  v_new_stats := jsonb_build_object(
    'pro', jsonb_build_object(
      'wins', v_user.pro_wins,
      'losses', v_user.pro_losses,
      'break_and_run', v_user.pro_break_and_run_count
    ),
    'student', jsonb_build_object(
      'wins', v_user.student_wins,
      'losses', v_user.student_losses,
      'break_and_run', v_user.student_break_and_run_count
    ),
    'overall', jsonb_build_object(
      'wins', v_user.pro_wins + v_user.student_wins,
      'losses', v_user.pro_losses + v_user.student_losses,
      'break_and_run', v_user.pro_break_and_run_count + v_user.student_break_and_run_count
    )
  );

  INSERT INTO admin_audit_log (admin_id, action, target_user_id, details)
  VALUES (
    v_admin_id,
    'update_division_stats',
    p_user_id,
    jsonb_build_object(
      'division', v_division,
      'mode', v_mode,
      'award_at', v_ref,
      'award_year_nz', v_current_year,
      'input', jsonb_build_object(
        'wins', COALESCE(p_wins, 0),
        'losses', COALESCE(p_losses, 0),
        'break_and_run', COALESCE(p_break_and_run, 0)
      ),
      'reason', v_reason,
      'before', v_old_stats,
      'after', v_new_stats
    )
  );

  RETURN json_build_object(
    'success', true,
    'division', v_division,
    'mode', v_mode,
    'stats', v_new_stats,
    'year', v_current_year
  );
END;
$function$;

GRANT EXECUTE ON FUNCTION public.admin_update_division_stats(uuid, text, integer, integer, integer, text, uuid, text, timestamptz) TO PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_update_division_stats(uuid, text, integer, integer, integer, text, uuid, text, timestamptz) TO anon;
GRANT EXECUTE ON FUNCTION public.admin_update_division_stats(uuid, text, integer, integer, integer, text, uuid, text, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_update_division_stats(uuid, text, integer, integer, integer, text, uuid, text, timestamptz) TO service_role;
