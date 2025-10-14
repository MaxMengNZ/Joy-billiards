# 🚀 Quick Setup Guide - Joy Billiards Tournament System

Follow these steps to get the tournament system running locally.

---

## ⚡ Quick Start (5 minutes)

### Step 1: Install Dependencies
```bash
npm install
```

### Step 2: Configure Environment Variables

Create a `.env` file in the project root:

```env
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=your_anon_key_here
```

**To get your Anon Key:**
1. Go to https://app.supabase.com
2. Select your project
3. Navigate to Settings → API
4. Copy the `anon` `public` key

### Step 3: Set Up Database

1. Open Supabase SQL Editor: https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql
2. Create a new query
3. Copy **all contents** from `supabase-migration.sql`
4. Paste and click **Run**

Wait for "Success" message. This creates:
- 4 tables (players, tournaments, tournament_participants, matches)
- All indexes and relationships
- Row Level Security policies
- Sample data

### Step 4: Start the App
```bash
npm run dev
```

Open http://localhost:3000 in your browser.

---

## ✅ Verify Setup

### Check Database Connection
Look at the footer of the website:
- 🟢 **Database Connected** = Everything works!
- 🔴 **Database Disconnected** = Check your `.env` file

### Test the System
1. Go to **Players** → Click "Add New Player" → Create a test player
2. Go to **Tournaments** → Click "Create Tournament" → Create a test tournament
3. If both work, setup is complete! 🎉

---

## 🔍 Troubleshooting

### "Database Disconnected"
**Problem**: Red indicator in footer

**Solutions**:
1. Check `.env` file exists in project root
2. Verify `VITE_SUPABASE_ANON_KEY` is set correctly
3. Restart dev server: Stop (`Ctrl+C`) and run `npm run dev` again

### "relation does not exist" Error
**Problem**: Tables not created

**Solution**: 
Run the migration SQL again in Supabase SQL Editor

### Migration SQL Fails
**Problem**: Errors when running `supabase-migration.sql`

**Solutions**:
1. Drop all tables first:
```sql
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS tournament_participants CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS players CASCADE;
```
2. Run the migration SQL again

### Port 3000 Already in Use
**Solution**:
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill

# Or use a different port
npm run dev -- --port 3001
```

---

## 📋 Complete Database Schema

Run this if you need to recreate the database:

```sql
-- The complete migration is in supabase-migration.sql
-- Just copy/paste that entire file into Supabase SQL Editor
```

---

## 🎯 Next Steps

Once setup is complete:

1. **Create Players**: Add your billiards players
2. **Create Tournament**: Set up your first tournament
3. **Add Participants**: Register players to the tournament
4. **Schedule Matches**: Create the match schedule
5. **Record Results**: Update scores as matches complete

---

## 🆘 Still Having Issues?

### Check Node Version
```bash
node -v
# Should be v18 or higher
```

If not, install from https://nodejs.org

### Clear Everything and Start Over
```bash
# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear Vite cache
rm -rf .vite

# Restart dev server
npm run dev
```

### Check Supabase Project Status
1. Go to https://app.supabase.com
2. Ensure your project is "Active" (not paused)
3. Check if you can see tables in Table Editor

---

## 📞 Need Help?

Contact Joy Billiards:
- 📍 88 Tristram Street, Hamilton Central
- 📞 022 166 0688

---

**Happy Tournament Managing! 🎱**


