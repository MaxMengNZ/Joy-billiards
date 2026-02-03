
}-- ============================================
-- 🔧 IMMEDIATE FIX - Fix Tournament Insert Issue
-- ============================================
-- Run this in Supabase SQL Editor RIGHT NOW
-- ============================================

-- Step 1: Check current RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'tournaments'
ORDER BY policyname;

-- Step 2: Drop ALL existing policies on tournaments
DROP POLICY IF EXISTS "Allow public read access to tournaments" ON tournaments;
DROP POLICY IF EXISTS "Allow all operations on tournaments" ON tournaments;
DROP POLICY IF EXISTS "Admins can insert tournaments" ON tournaments;
DROP POLICY IF EXISTS "Admins can create tournaments" ON tournaments;
DROP POLICY IF EXISTS "Admins can manage tournaments" ON tournaments;
DROP POLICY IF EXISTS "Admins can update tournaments" ON tournaments;
DROP POLICY IF EXISTS "Admins can delete tournaments" ON tournaments;
DROP POLICY IF EXISTS "Anyone can view tournaments" ON tournaments;

-- Step 3: Temporarily DISABLE RLS to test
ALTER TABLE tournaments DISABLE ROW LEVEL SECURITY;

-- Step 4: Test insert (should work now)
-- You can test manually in Supabase SQL Editor:
-- INSERT INTO tournaments (name, description, tournament_type, start_date, entry_fee, max_players, status)
-- VALUES ('Test Tournament', 'Test Description', 'single_elimination', NOW(), 20, 16, 'registration')
-- RETURNING *;

-- Step 5: Re-enable RLS and create simple policy
ALTER TABLE tournaments ENABLE ROW LEVEL SECURITY;

-- Step 6: Create simple policy that allows all authenticated users to insert
CREATE POLICY "Allow authenticated users to insert tournaments" ON tournaments
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Step 7: Create policy for admins to do everything
CREATE POLICY "Admins can manage tournaments" ON tournaments
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() 
            AND u.role = 'admin'
            AND u.is_active = true
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.auth_id = auth.uid() 
            AND u.role = 'admin'
            AND u.is_active = true
        )
    );

-- Step 8: Allow everyone to read tournaments
CREATE POLICY "Anyone can view tournaments" ON tournaments
    FOR SELECT
    USING (true);

-- Step 9: Check for triggers that might be blocking
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE event_object_table = 'tournaments';

-- Step 10: Verify the fix
SELECT 
    'RLS Status' as check_type,
    CASE 
        WHEN (SELECT relrowsecurity FROM pg_class WHERE relname = 'tournaments') 
        THEN 'ENABLED' 
        ELSE 'DISABLED' 
    END as status
UNION ALL
SELECT 
    'Policy Count' as check_type,
    COUNT(*)::text as status
FROM pg_policies 
WHERE tablename = 'tournaments';

-- ============================================
-- ✅ AFTER RUNNING THIS:
-- 1. Refresh your browser
-- 2. Try creating tournament again
-- 3. If still fails, check Supabase Dashboard → Logs for errors
-- ============================================


