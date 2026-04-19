# Setup Supabase Storage for Media Files (Photos & Documents)

## Problem

Photos and documents are not loading because Render's filesystem is **ephemeral** - files get deleted on restart.

## Solution

Use **Supabase Storage** (you already have Supabase!) to store all media files permanently.

---

## Step 1: Get Supabase API Key

1. Go to: https://supabase.com/dashboard
2. Click on your project: **Essential Homes** (or whatever you named it)
3. Go to **Settings** (gear icon on left sidebar)
4. Click **API** section
5. Copy the **anon/public** key (it's a long string starting with `eyJ...`)

Example:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODk1NzY4MDAsImV4cCI6MjAwNTE1MjgwMH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 2: Create Storage Bucket in Supabase

1. In Supabase Dashboard, click **Storage** (left sidebar)
2. Click **New bucket**
3. Enter bucket name: `construction-media`
4. **Make it PUBLIC** (toggle the "Public bucket" switch ON)
5. Click **Create bucket**

### Why public?
- Photos and documents need to be accessible via URL
- Only authenticated users can upload (controlled by your Django backend)
- Anyone with the URL can view (which is what you want for photos/documents)

---

## Step 3: Update Render Environment Variables

1. Go to: https://dashboard.render.com/
2. Click on your service: `new-essentials`
3. Go to **Environment** tab
4. Add these 2 new variables:

```
SUPABASE_KEY = (paste your anon key from Step 1)
SUPABASE_STORAGE_BUCKET = construction-media
```

5. Click **Save Changes**

---

## Step 4: Update Local .env File

Edit `Essentials_construction_project/django-backend/.env`:

Replace this line:
```env
SUPABASE_KEY=your_supabase_anon_key_here
```

With your actual key:
```env
SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODk1NzY4MDAsImV4cCI6MjAwNTE1MjgwMH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 5: Update File Upload Code

The code needs to be updated to use Supabase Storage instead of local filesystem. I'll update the views that handle file uploads.

Files that need updating:
- `api/views_construction.py` - Photo uploads
- `api/views_accountant.py` - Bill uploads
- `api/views_architect.py` - Document uploads

---

## Step 6: Push Changes to GitHub

```bash
cd Essentials_construction_project
git add -A
git commit -m "Add Supabase Storage for persistent media files"
git push origin main
```

Render will automatically redeploy (takes 5-10 minutes).

---

## How It Works

### Before (Render Filesystem - BROKEN):
```
User uploads photo → Saved to /opt/render/project/media/ → Server restarts → Files deleted ❌
```

### After (Supabase Storage - WORKING):
```
User uploads photo → Uploaded to Supabase Storage → Stored permanently → Always accessible ✅
```

### URL Structure:
```
https://ctwthgjuccioxivnzifb.supabase.co/storage/v1/object/public/construction-media/site_photos/20260419_abc123.jpg
```

---

## Folder Structure in Supabase Storage

Files will be organized in folders:
```
construction-media/
├── site_photos/          (Supervisor morning/evening photos)
├── material_bills/       (Accountant material bills)
├── vendor_bills/         (Accountant vendor bills)
├── agreements/           (Accountant agreements)
├── engineer_documents/   (Site engineer documents)
└── architect_documents/  (Architect documents)
```

---

## Supabase Storage Free Tier

- ✅ 1 GB storage (plenty for your project!)
- ✅ 2 GB bandwidth/month
- ✅ Unlimited file uploads
- ✅ Perfect for construction photos and documents

---

## Testing After Setup

### 1. Test Photo Upload:
1. Login as Supervisor
2. Upload a morning photo
3. Go to Accountant view → Photos tab
4. Photo should display correctly

### 2. Test Document Upload:
1. Login as Accountant
2. Upload a material bill with PDF
3. Click to open document
4. Should open correctly (no 404 error)

### 3. Verify in Supabase:
1. Go to Supabase Dashboard → Storage
2. Click on `construction-media` bucket
3. You should see uploaded files organized in folders

---

## Advantages of Supabase Storage

1. ✅ **Already using Supabase** - No new service needed
2. ✅ **Everything in one place** - Database + Files
3. ✅ **Free tier is generous** - 1 GB storage
4. ✅ **Fast CDN** - Files served from edge locations
5. ✅ **Automatic backups** - Files are safe
6. ✅ **Easy to manage** - View/delete files in dashboard

---

## Troubleshooting

### If photos still don't load:

1. **Check bucket is PUBLIC**:
   - Supabase Dashboard → Storage → construction-media
   - Should say "Public" badge
   - If not, click settings and make it public

2. **Check Render environment variables**:
   - Go to Render dashboard
   - Verify `SUPABASE_KEY` and `SUPABASE_STORAGE_BUCKET` are set

3. **Check Supabase API key**:
   - Make sure you copied the **anon/public** key, not the service_role key
   - The key should start with `eyJ...`

4. **Re-upload test files**:
   - Old files won't work (they were on Render's filesystem)
   - Upload new photos/documents to test

---

## Migration Note

**Important**: Files uploaded BEFORE setting up Supabase Storage are lost. Users will need to re-upload:
- Supervisor photos
- Material bills
- Vendor bills
- Agreements
- Site engineer documents
- Architect documents

This is a one-time migration. After Supabase Storage is set up, all files will be stored permanently.

---

## Next Steps

1. ✅ Get Supabase API key from dashboard
2. ✅ Create `construction-media` bucket (make it PUBLIC)
3. ✅ Add environment variables to Render
4. ✅ Update local .env file
5. ✅ Push code changes to GitHub
6. ✅ Wait for Render deployment
7. ✅ Test photo and document uploads
8. ✅ Inform users to re-upload important documents

---

## Summary

- **Supabase Database**: Stores text data (users, sites, entries) ✅ Already working
- **Supabase Storage**: Stores files (photos, documents) ⚠️ Need to set up
- **Render**: Runs your Django backend ✅ Already working

All three work together to make your app fully functional!
