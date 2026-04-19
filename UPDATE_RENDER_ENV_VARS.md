# Update Render Environment Variables

## Current Issue

✅ Local uploads work perfectly
❌ Production (Render) uploads don't work

## Why?

Render environment variables are NOT updated with the correct Supabase credentials.

---

## Step-by-Step: Update Render Environment Variables

### 1. Go to Render Dashboard

Open: https://dashboard.render.com/

### 2. Select Your Service

Click on: `new-essentials` (or whatever your service is named)

### 3. Go to Environment Tab

Click **Environment** in the left sidebar

### 4. Update/Add These Variables

You need to update or add these 3 variables:

#### Variable 1: SUPABASE_KEY
```
SUPABASE_KEY
```
Value:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNzQzODAsImV4cCI6MjA4MTY1MDM4MH0.xtE4a1nn-sDTe-HWMkJS-RA_ndahMy1iKUjG6dXE_RY
```

#### Variable 2: SUPABASE_STORAGE_BUCKET
```
SUPABASE_STORAGE_BUCKET
```
Value:
```
Media
```

#### Variable 3: SUPABASE_URL (should already exist)
```
SUPABASE_URL
```
Value:
```
https://ctwthgjuccioxivnzifb.supabase.co
```

### 5. Save Changes

Click **Save Changes** button at the bottom

### 6. Wait for Redeploy

Render will automatically redeploy your service (takes 5-10 minutes)

Watch the **Logs** tab to see deployment progress

---

## How to Verify It's Working

### Method 1: Check Render Logs

1. Go to Render Dashboard → Your Service → Logs
2. Look for any errors related to Supabase or file uploads
3. Should see successful upload messages

### Method 2: Test Photo Upload

1. Open your mobile app
2. Login as Supervisor
3. Go to a site
4. Upload a morning or evening photo
5. Go to Supabase Dashboard → Storage → Media bucket
6. You should see the photo in `site_photos/` folder

### Method 3: Check Accountant View

1. Login as Accountant
2. Go to Photos tab
3. Photos should display correctly (not broken images)

---

## Current Environment Variables on Render

You should have these variables set:

```
SECRET_KEY = django-insecure-essential-homes-2024-change-in-production
DEBUG = False
ALLOWED_HOSTS = *
JWT_SECRET_KEY = essential-homes-jwt-secret-2024-change-in-production

DB_NAME = postgres
DB_USER = postgres
DB_PASSWORD = Appdevlopment@2026
DB_HOST = db.ctwthgjuccioxivnzifb.supabase.co
DB_PORT = 5432

SUPABASE_URL = https://ctwthgjuccioxivnzifb.supabase.co
SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNzQzODAsImV4cCI6MjA4MTY1MDM4MH0.xtE4a1nn-sDTe-HWMkJS-RA_ndahMy1iKUjG6dXE_RY
SUPABASE_STORAGE_BUCKET = Media

PYTHON_VERSION = 3.11.0
```

---

## What Happens After Update

### Before (Current State):
```
Supervisor uploads photo → Render tries to save locally → File saved temporarily → Server restarts → File deleted → Broken image ❌
```

### After (Fixed):
```
Supervisor uploads photo → Render uploads to Supabase Storage → File stored permanently → Always accessible → Photo displays correctly ✅
```

---

## File Organization in Supabase Storage

After fixing, files will be organized like this:

```
Media/
├── site_photos/
│   ├── 20260419_213619_abc123.jpg (Supervisor morning photo)
│   ├── 20260419_183045_def456.jpg (Supervisor evening photo)
│   └── ...
├── material_bills/
│   ├── 20260419_140522_ghi789.pdf (Bill document)
│   ├── 20260419_140522_ghi789.jpg (Bill photo)
│   └── ...
├── vendor_bills/
│   └── ...
├── agreements/
│   └── ...
└── documents/
    └── ...
```

Each file has:
- Timestamp: `20260419_213619` (YYYYMMDD_HHMMSS)
- Unique ID: `abc123` (8 characters)
- Extension: `.jpg`, `.pdf`, etc.

---

## Troubleshooting

### If photos still don't appear after update:

1. **Check Render deployment completed**:
   - Go to Render Dashboard → Logs
   - Should see "Deploy succeeded" message
   - Wait 5-10 minutes for full deployment

2. **Check environment variables are saved**:
   - Go to Environment tab
   - Verify all 3 variables are present
   - Values should match exactly (no extra spaces)

3. **Check Render logs for errors**:
   - Go to Logs tab
   - Look for "Supabase" or "upload" errors
   - Should see successful upload messages

4. **Re-upload test photo**:
   - Old photos won't work (they were saved locally)
   - Upload a NEW photo to test
   - Check Supabase Storage bucket for the file

5. **Verify Supabase bucket is public**:
   - Go to Supabase Dashboard → Storage → Media
   - Should have "PUBLIC" badge
   - If not, click Settings and toggle "Public bucket" ON

---

## Summary

The code is working perfectly! The only issue is that Render doesn't have the updated environment variables.

Steps to fix:
1. ✅ Go to Render Dashboard
2. ✅ Update SUPABASE_KEY environment variable
3. ✅ Update SUPABASE_STORAGE_BUCKET to "Media"
4. ✅ Save changes
5. ✅ Wait for redeploy (5-10 minutes)
6. ✅ Test photo upload
7. ✅ Verify file appears in Supabase Storage bucket

After this, all photo and document uploads will work permanently on both mobile and web!
