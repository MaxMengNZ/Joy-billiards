# ⚡ 3-Minute Quick Start

Get the Joy Billiards Tournament System running in 3 minutes!

---

## Step 1: Install (30 seconds)

```bash
cd /Users/mengyang/Desktop/JoyBilliards
npm install
```

---

## Step 2: Configure Supabase (1 minute)

### 2.1 Get Your Anon Key
1. Open: https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/settings/api
2. Copy the `anon` `public` key (starts with `eyJ...`)

### 2.2 Create .env File
Create `/Users/mengyang/Desktop/JoyBilliards/.env`:

```env
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=paste_your_key_here
```

---

## Step 3: Setup Database (1 minute)

1. Open: https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql/new
2. Copy ALL content from `supabase-migration.sql`
3. Paste and click **RUN**
4. Wait for "Success" ✅

---

## Step 4: Start! (30 seconds)

```bash
npm run dev
```

Open: http://localhost:3000

---

## ✅ Success Check

Look at the footer:
- 🟢 **Database Connected** = You're ready! 🎉
- 🔴 **Database Disconnected** = Check your `.env` file

---

## 🎯 First Actions

1. Click **Players** → Add a test player
2. Click **Tournaments** → Create a tournament
3. Explore the system!

---

## 🆘 Problems?

**Database won't connect:**
- Check `.env` file exists
- Verify anon key is correct
- Restart: `Ctrl+C` then `npm run dev`

**Migration fails:**
- Run it again in SQL Editor
- Or see SETUP.md for detailed help

---

## 📚 Full Documentation

- `README.md` - Complete guide
- `SETUP.md` - Detailed setup
- `DEPLOYMENT.md` - Production deployment

---

**Happy tournament managing! 🎱**

Joy Billiards New Zealand
📍 88 Tristram Street, Hamilton Central
📞 022 166 0688


