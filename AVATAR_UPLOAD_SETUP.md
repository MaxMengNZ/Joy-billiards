# Avatar Upload Setup Guide

## Overview
The Battle Profile page now supports user avatar uploads. Users can click on their avatar (or the default 🎱 icon) to upload a custom profile picture.

## Database Changes
✅ **Completed**: Added `avatar_url` column to `users` table

## Storage Setup Required

### Step 1: Create Storage Bucket in Supabase Dashboard

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Storage** in the left sidebar
4. Click **"New bucket"**
5. Configure the bucket:
   - **Name**: `avatars`
   - **Public bucket**: ✅ **Yes** (check this box)
   - **File size limit**: 5 MB (recommended)
   - **Allowed MIME types**: `image/*` (or leave empty for all types)
6. Click **"Create bucket"**

### Step 2: Set Storage Policies (RLS)

After creating the bucket, set up Row Level Security policies:

1. Go to **Storage** → **Policies** → **avatars**
2. Click **"New Policy"**
3. Create the following policies:

#### Policy 1: Users can upload their own avatars
- **Policy name**: "Users can upload own avatars"
- **Allowed operation**: INSERT
- **Policy definition**:
```sql
(bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])
```

#### Policy 2: Users can update their own avatars
- **Policy name**: "Users can update own avatars"
- **Allowed operation**: UPDATE
- **Policy definition**:
```sql
(bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])
```

#### Policy 3: Users can delete their own avatars
- **Policy name**: "Users can delete own avatars"
- **Allowed operation**: DELETE
- **Policy definition**:
```sql
(bucket_id = 'avatars'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])
```

#### Policy 4: Everyone can view avatars (public read)
- **Policy name**: "Public avatar access"
- **Allowed operation**: SELECT
- **Policy definition**:
```sql
bucket_id = 'avatars'::text
```

### Step 3: Verify Setup

1. Open the Battle page in your app
2. Click **"My Profile"**
3. Click on the avatar (🎱 icon)
4. Select an image file
5. The avatar should upload and display

## File Structure

Avatars are stored in Supabase Storage with the following structure:
```
avatars/
  └── {user_id}/
      └── {timestamp}.{extension}
```

Example:
```
avatars/
  └── fae710eb-e11a-4ca6-b633-8adb6be93699/
      └── 1707123456789.jpg
```

## Features

- ✅ Click avatar to upload
- ✅ Image preview after upload
- ✅ Default 🎱 icon if no avatar
- ✅ File size validation (max 5MB)
- ✅ File type validation (images only)
- ✅ Loading state during upload
- ✅ Error handling

## Troubleshooting

### "Bucket not found" error
- Make sure the `avatars` bucket exists in Supabase Storage
- Verify the bucket name is exactly `avatars` (lowercase)

### "Permission denied" error
- Check that RLS policies are set up correctly
- Verify the user is authenticated

### Avatar not displaying
- Check that the bucket is set to **Public**
- Verify the `avatar_url` in the database is correct
- Check browser console for CORS errors
