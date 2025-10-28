-- Ensure check_email_exists works under RLS by running as SECURITY DEFINER
-- and explicitly referencing public.users

CREATE OR REPLACE FUNCTION public.check_email_exists(email text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.users u
    WHERE u.email = check_email_exists.email
  );
END;
$$;


