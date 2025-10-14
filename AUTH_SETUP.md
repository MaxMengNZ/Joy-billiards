# 🔐 Authentication System Setup Guide

## Overview

Joy Billiards now has a complete authentication system with:
- ✅ User registration and login
- ✅ Two user roles: **Admin** and **Player**
- ✅ Role-based access control
- ✅ Protected routes
- ✅ Supabase Auth integration

---

## 🚀 Setup Steps

### Step 1: Run the Authentication Migration

1. Open Supabase SQL Editor:
   ```
   https://app.supabase.com/project/qnwtqgdbgyqwpsdqvxfl/sql/new
   ```

2. Copy **ALL** content from `supabase-auth-migration.sql`

3. Paste and click **RUN**

4. Wait for "Success" ✅

This migration creates:
- `user_profiles` table with roles
- Automatic profile creation trigger
- Role-based RLS policies
- Helper functions for permission checks

---

### Step 2: Enable Email Auth in Supabase

1. Go to Supabase Dashboard → **Authentication** → **Providers**

2. Enable **Email** provider:
   - ✅ Enable email provider
   - ✅ Confirm email (recommended but optional for testing)

3. Configure email templates (optional):
   - Go to **Authentication** → **Email Templates**
   - Customize confirmation and password reset emails

---

### Step 3: Create First Admin User

#### Option A: Through the Application

1. Run the application: `npm run dev`

2. Go to http://localhost:3000/register

3. Fill in:
   - Full Name: Your name
   - Email: your.email@example.com
   - Password: (min 6 characters)
   - Role: **Administrator**

4. Click **Sign Up**

5. Check your email and confirm (if email confirmation enabled)

6. Login at http://localhost:3000/login

#### Option B: Through Supabase Dashboard

1. Go to **Authentication** → **Users**

2. Click **Add User**

3. Fill in email and password

4. After user is created, go to **SQL Editor**

5. Run this query:
```sql
UPDATE user_profiles 
SET role = 'admin' 
WHERE email = 'your.email@example.com';
```

---

## 👥 User Roles

### Admin Role 👑
**Full Access:**
- ✅ Manage all players
- ✅ Create/edit/delete tournaments
- ✅ Manage tournament participants
- ✅ Create and update matches
- ✅ View admin dashboard
- ✅ Manage user accounts (change roles, activate/deactivate users)

### Player Role 🎯
**Limited Access:**
- ✅ View tournaments
- ✅ View matches
- ✅ View players (if authenticated)
- ✅ Register for tournaments (their own account)
- ❌ Cannot create/edit tournaments
- ❌ Cannot manage other users

---

## 🛣️ Protected Routes

### Public Routes (No Login Required)
- `/` - Home page
- `/tournaments` - View tournaments
- `/matches` - View matches
- `/login` - Login page
- `/register` - Registration page

### Authenticated Routes (Login Required)
- `/players` - Players management

### Admin Only Routes
- `/admin` - Admin dashboard
- Full CRUD on players, tournaments, matches

---

## 🔐 Security Features

### Database Level
- ✅ **Row Level Security (RLS)** enabled on all tables
- ✅ Users can only see their own profile
- ✅ Admins can see and modify all profiles
- ✅ Players can only register themselves for tournaments
- ✅ Admins have full control over tournaments and matches

### Application Level
- ✅ Route guards prevent unauthorized access
- ✅ UI elements hide/show based on user role
- ✅ Server-side validation through Supabase RLS

---

## 🧪 Testing the System

### Test as Admin

1. Register/Login as Admin

2. You should see:
   - "Admin" link in navigation
   - Crown icon (👑) next to your name
   - Full access to all features

3. Go to `/admin` dashboard:
   - View all users
   - Change user roles
   - Activate/deactivate users
   - Manage players, tournaments, matches

### Test as Player

1. Register/Login as Player

2. You should see:
   - Limited navigation
   - Cannot access `/admin`
   - Can view tournaments and matches
   - Can register for tournaments

---

## 🔄 User Management

### As Admin, you can:

1. **View All Users**: `/admin` dashboard shows all registered users

2. **Change User Roles**:
   - Click "Make Admin" to promote player to admin
   - Click "Make Player" to demote admin to player

3. **Activate/Deactivate Users**:
   - Click "Deactivate" to disable user access
   - Click "Activate" to re-enable user access

4. **Link Players to User Accounts**:
   - Edit player record
   - Link to user profile (coming soon)

---

## 📝 Password Reset

### For Users:

1. On login page, click **"Forgot Password?"**

2. Enter your email address

3. Check email for reset link

4. Click link and set new password

### For Admins:

You can temporarily disable a user's account if needed through the Admin Dashboard.

---

## 🎯 Common Workflows

### Register New Player

1. Player goes to `/register`
2. Fills in details, selects "Player" role
3. Submits registration
4. Confirms email (if enabled)
5. Can now login and participate in tournaments

### Admin Creates Tournament

1. Admin logs in
2. Goes to "Tournaments"
3. Clicks "Create Tournament"
4. Fills in details
5. Tournament is created
6. Players can now register

### Player Registers for Tournament

1. Player logs in
2. Browses tournaments
3. Clicks on tournament
4. Clicks "Add Participant"
5. Selects themselves
6. Registered!

---

## 🆘 Troubleshooting

### "Database Disconnected"
- Check `.env` file has correct Supabase credentials
- Restart development server

### Can't Login
- Check email and password are correct
- Verify user exists in **Authentication** → **Users**
- Check user is active in `user_profiles` table

### Permission Denied
- Check user role in `user_profiles` table
- Verify RLS policies are enabled
- Check route guards in `router/index.js`

### Email Not Sending
- Verify email provider is enabled in Supabase
- Check Supabase email quota (free tier has limits)
- For development, you can disable email confirmation

---

## 🔧 Configuration Options

### Disable Email Confirmation (Development Only)

In Supabase Dashboard:
1. Go to **Authentication** → **Providers**
2. Click on **Email**
3. Uncheck "Confirm email"
4. Users can login immediately after registration

### Custom Email Templates

1. Go to **Authentication** → **Email Templates**
2. Edit templates for:
   - Confirmation email
   - Password reset
   - Email change
3. Add your branding and custom messages

---

## 📊 Database Schema

### user_profiles Table

```sql
- id (UUID) - Links to auth.users.id
- email (VARCHAR) - User email
- full_name (VARCHAR) - Display name
- role (user_role) - 'admin' or 'player'
- player_id (UUID) - Link to players table (optional)
- is_active (BOOLEAN) - Account status
- created_at, updated_at (TIMESTAMP)
```

---

## 🎉 What's New

### Features Added:

1. ✅ **Login Page** (`/login`)
   - Email/password authentication
   - Forgot password link
   - Link to registration

2. ✅ **Registration Page** (`/register`)
   - User registration with role selection
   - Password confirmation
   - Email verification

3. ✅ **Admin Dashboard** (`/admin`)
   - User management
   - Role assignment
   - User activation/deactivation
   - Quick action links

4. ✅ **Auth Store** (`stores/authStore.js`)
   - Complete authentication state management
   - Login/logout/register methods
   - Profile management
   - Admin functions

5. ✅ **Route Guards**
   - Automatic authentication checking
   - Role-based route protection
   - Redirect to login for protected routes

6. ✅ **UI Updates**
   - User name display in header
   - Login/logout buttons
   - Role indicator (crown for admin)
   - Conditional navigation based on role

---

## 🚀 Next Steps

### Recommended Enhancements:

1. **Email Verification**: Enable in production
2. **Password Requirements**: Enforce stronger passwords
3. **Session Timeout**: Configure in Supabase
4. **2FA**: Add two-factor authentication
5. **Audit Log**: Track user actions
6. **Profile Pictures**: Add avatar upload

---

## 📞 Support

For issues or questions:
- Check this guide
- Review `supabase-auth-migration.sql` for database structure
- Check Supabase Auth documentation
- Contact Joy Billiards staff

---

**Authentication System is Ready!** 🔐✨

Login credentials for testing:
- Admin: (create your first admin user)
- Player: (register as player)

Start managing users at: http://localhost:3000/admin


