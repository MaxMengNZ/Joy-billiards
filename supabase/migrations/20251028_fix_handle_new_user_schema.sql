-- Qualify public.users in handle_new_user and keep membership card sequence logic

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_name TEXT;
  membership_card TEXT;
  next_number INTEGER;
BEGIN
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'full_name',
    CASE WHEN NEW.email IS NOT NULL THEN INITCAP(REPLACE(SPLIT_PART(NEW.email, '@', 1), '.', ' ')) ELSE 'User' END
  );

  SELECT COALESCE(
    MAX(CAST(SPLIT_PART(u.membership_card_number, '-', 3) AS INTEGER)),
    574736
  ) + 1
  INTO next_number
  FROM public.users u
  WHERE u.membership_card_number LIKE 'JB-2025-%';

  LOOP
    IF EXISTS (
      SELECT 1 FROM public.users pu
      WHERE pu.membership_card_number = 'JB-2025-' || LPAD(next_number::TEXT, 6, '0')
    ) THEN
      next_number := next_number + 1;
    ELSE
      EXIT;
    END IF;
  END LOOP;

  membership_card := 'JB-2025-' || LPAD(next_number::TEXT, 6, '0');

  INSERT INTO public.users (
    auth_id,
    name,
    email,
    phone,
    birthday,
    address,
    id_card,
    membership_card_number,
    membership_expires_at,
    email_verified,
    email_verification_token,
    email_verification_expires_at,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    user_name,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    CASE
      WHEN NEW.raw_user_meta_data->>'birthday' IS NOT NULL AND NEW.raw_user_meta_data->>'birthday' != ''
      THEN (NEW.raw_user_meta_data->>'birthday')::date
      ELSE NULL
    END,
    COALESCE(NEW.raw_user_meta_data->>'address', ''),
    COALESCE(NEW.raw_user_meta_data->>'id_card', ''),
    membership_card,
    CASE
      WHEN NEW.raw_user_meta_data->>'membership_expires_at' IS NOT NULL AND NEW.raw_user_meta_data->>'membership_expires_at' != ''
      THEN (NEW.raw_user_meta_data->>'membership_expires_at')::timestamp
      ELSE NULL
    END,
    COALESCE(NEW.email_confirmed_at IS NOT NULL, FALSE),
    gen_random_uuid()::text,
    NOW() + INTERVAL '7 days',
    NOW(),
    NOW()
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


