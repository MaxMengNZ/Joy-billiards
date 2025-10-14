-- Fix handle_new_user trigger function for user registration
-- Date: 2025-01-14
-- Issue: User registration failing due to deleted fields in trigger function

-- 修复 handle_new_user 触发器函数，移除已删除的字段
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
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
  
  -- Insert new user profile (移除已删除的字段)
  INSERT INTO public.users (
    auth_id,
    name,
    email,
    membership_level,
    membership_card_number,
    ranking_level,
    wins,
    losses,
    break_and_run_count,
    loyalty_points,
    membership_balance,
    is_active,
    role
  ) VALUES (
    NEW.id,
    user_name,
    NEW.email,
    'lite',
    card_number_str,
    'beginner',
    0,
    0,
    0,
    0.00,
    0.00,
    true,
    'player'
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 确保触发器存在并正常工作
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
