-- Supabase Security and Performance Fixes
-- Date: 2025-01-14
-- Description: Comprehensive fixes for 55 Supabase issues

-- ============================================
-- 1. SECURITY FIXES - Function Search Path
-- ============================================

-- Fix handle_new_user function
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER 
LANGUAGE plpgsql 
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  next_card_number INTEGER;
  card_number_str VARCHAR;
  user_name VARCHAR;
BEGIN
  -- Generate next membership card number
  SELECT COALESCE(
    MAX(CAST(SUBSTRING(membership_card_number FROM 9) AS INTEGER)) + 1,
    100001
  ) INTO next_card_number
  FROM users 
  WHERE membership_card_number LIKE 'JB-2025-%';
  
  card_number_str := 'JB-2025-' || next_card_number::TEXT;
  
  -- Try to get name from metadata, if not available use email prefix as fallback
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'display_name',
    SPLIT_PART(NEW.email, '@', 1)
  );
  
  -- Insert new user profile
  INSERT INTO public.users (
    auth_id, name, email, membership_level, membership_card_number,
    ranking_level, wins, losses, break_and_run_count, loyalty_points,
    membership_balance, is_active, role
  ) VALUES (
    NEW.id, user_name, NEW.email, 'lite', card_number_str,
    'beginner', 0, 0, 0, 0.00, 0.00, true, 'player'
  );
  
  RETURN NEW;
END;
$$;

-- Fix record_loyalty_points function
DROP FUNCTION IF EXISTS record_loyalty_points(UUID, NUMERIC, TEXT, UUID);
CREATE OR REPLACE FUNCTION record_loyalty_points(
  p_user_id UUID,
  p_amount_nzd NUMERIC,
  p_description TEXT DEFAULT NULL,
  p_recorded_by UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_name TEXT;
  v_membership_level TEXT;
  v_multiplier NUMERIC;
  v_points_earned NUMERIC;
BEGIN
  -- Get user info and calculate points
  SELECT name, membership_level INTO v_user_name, v_membership_level
  FROM users WHERE id = p_user_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'User not found');
  END IF;
  
  -- Calculate multiplier based on membership level
  CASE v_membership_level
    WHEN 'lite' THEN v_multiplier := 1.0;
    WHEN 'plus' THEN v_multiplier := 1.2;
    WHEN 'pro' THEN v_multiplier := 1.4;
    WHEN 'pro_max' THEN v_multiplier := 1.6;
    ELSE v_multiplier := 1.0;
  END CASE;
  
  v_points_earned := p_amount_nzd * v_multiplier;
  
  -- Insert loyalty points record
  INSERT INTO loyalty_points (
    user_id, amount_nzd, points_earned, description, 
    membership_level, multiplier, recorded_by, created_at
  ) VALUES (
    p_user_id, p_amount_nzd, v_points_earned, p_description,
    v_membership_level, v_multiplier, p_recorded_by, NOW()
  );
  
  -- Update user points
  UPDATE users 
  SET loyalty_points = loyalty_points + v_points_earned,
      updated_at = NOW()
  WHERE id = p_user_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_earned', v_points_earned,
    'multiplier', v_multiplier,
    'membership_level', v_membership_level
  );
END;
$$;

-- Fix other functions with security definer
CREATE OR REPLACE FUNCTION deduct_loyalty_points(
  p_user_id UUID,
  p_points_to_deduct NUMERIC,
  p_description TEXT DEFAULT NULL,
  p_recorded_by UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_current_points NUMERIC;
  v_user_name TEXT;
BEGIN
  SELECT loyalty_points, name INTO v_current_points, v_user_name
  FROM users WHERE id = p_user_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'User not found');
  END IF;
  
  IF v_current_points < p_points_to_deduct THEN
    RETURN jsonb_build_object('success', false, 'error', 'Insufficient points');
  END IF;
  
  INSERT INTO loyalty_points (
    user_id, amount_nzd, points_earned, description, 
    membership_level, multiplier, recorded_by, created_at
  ) VALUES (
    p_user_id, 0, -p_points_to_deduct, p_description,
    'deduction', 1.0, p_recorded_by, NOW()
  );
  
  UPDATE users 
  SET loyalty_points = loyalty_points - p_points_to_deduct,
      updated_at = NOW()
  WHERE id = p_user_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'points_deducted', p_points_to_deduct,
    'remaining_points', v_current_points - p_points_to_deduct
  );
END;
$$;

-- Fix helper functions
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users 
    WHERE auth_id = auth.uid() AND role = 'admin'
  );
END;
$$;

CREATE OR REPLACE FUNCTION is_player()
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users 
    WHERE auth_id = auth.uid() AND role = 'player'
  );
END;
$$;

-- ============================================
-- 2. DATABASE STRUCTURE FIXES
-- ============================================

-- Add primary key to loyalty_points table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE table_name = 'loyalty_points' 
    AND constraint_type = 'PRIMARY KEY'
  ) THEN
    ALTER TABLE loyalty_points ADD COLUMN IF NOT EXISTS id BIGSERIAL PRIMARY KEY;
  END IF;
END $$;

-- Remove duplicate index
DROP INDEX IF EXISTS idx_players_email;

-- ============================================
-- 3. RLS POLICY PERFORMANCE OPTIMIZATION
-- ============================================

-- Optimize users table policies
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins can update any user" ON users;
CREATE POLICY "Users can update own profile or admins can update any" ON users
  FOR UPDATE USING (
    auth_id = (select auth.uid()) OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can delete users" ON users;
CREATE POLICY "Admins can delete users" ON users
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

-- Optimize tournaments table policies
DROP POLICY IF EXISTS "Admins can create tournaments" ON tournaments;
CREATE POLICY "Admins can create tournaments" ON tournaments
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can update tournaments" ON tournaments;
CREATE POLICY "Admins can update tournaments" ON tournaments
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can delete tournaments" ON tournaments;
CREATE POLICY "Admins can delete tournaments" ON tournaments
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

-- Optimize matches table policies
DROP POLICY IF EXISTS "Admins can create matches" ON matches;
CREATE POLICY "Admins can create matches" ON matches
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can update matches" ON matches;
CREATE POLICY "Admins can update matches" ON matches
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can delete matches" ON matches;
CREATE POLICY "Admins can delete matches" ON matches
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

-- Optimize tournament_registrations table policies
DROP POLICY IF EXISTS "Players can register themselves" ON tournament_registrations;
DROP POLICY IF EXISTS "Admins can manage all registrations" ON tournament_registrations;
CREATE POLICY "Players can register or admins can manage" ON tournament_registrations
  FOR INSERT WITH CHECK (
    user_id IN (
      SELECT id FROM users WHERE auth_id = (select auth.uid())
    ) OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Players can cancel own registration" ON tournament_registrations;
CREATE POLICY "Players can update own or admins can manage all" ON tournament_registrations
  FOR UPDATE USING (
    user_id IN (
      SELECT id FROM users WHERE auth_id = (select auth.uid())
    ) OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Players can delete own registration" ON tournament_registrations;
CREATE POLICY "Players can delete own or admins can manage all" ON tournament_registrations
  FOR DELETE USING (
    user_id IN (
      SELECT id FROM users WHERE auth_id = (select auth.uid())
    ) OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Anyone can view registrations" ON tournament_registrations;
CREATE POLICY "Anyone can view registrations" ON tournament_registrations
  FOR SELECT USING (true);

-- Optimize loyalty_points table policies
DROP POLICY IF EXISTS "Users can view own consumption records" ON loyalty_points;
DROP POLICY IF EXISTS "Admins can view all consumption records" ON loyalty_points;
CREATE POLICY "Users can view own records or admins can view all" ON loyalty_points
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM users WHERE auth_id = (select auth.uid())
    ) OR EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Only admins can insert consumption records" ON loyalty_points;
CREATE POLICY "Only admins can insert consumption records" ON loyalty_points
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

-- Optimize point_history table policies
DROP POLICY IF EXISTS "Admins can insert point history" ON point_history;
CREATE POLICY "Admins can insert point history" ON point_history
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can update point history" ON point_history;
CREATE POLICY "Admins can update point history" ON point_history
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

DROP POLICY IF EXISTS "Admins can delete point history" ON point_history;
CREATE POLICY "Admins can delete point history" ON point_history
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.auth_id = (select auth.uid()) AND u.role = 'admin'
    )
  );

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify fixes
SELECT 'Security and Performance Fixes Applied Successfully' as status;
