# Fix Supabase Storage Upload Issue (RLS Policy)

## Current Status

✅ Connection to Supabase: **WORKING**
✅ Access to 'Media' bucket: **WORKING**
❌ File uploads: **BLOCKED by Row Level Security (RLS)**

## The Problem

Supabase has Row Level Security (RLS) enabled on the storage bucket. This blocks uploads unless you configure the correct policies.

Error: `new row violates row-level security policy`

---

## Solution: Configure Storage Policies in Supabase

### Step 1: Go to Supabase Dashboard

1. Open: https://supabase.com/dashboard
2. Select your project
3. Click **Storage** in left sidebar
4. Click on your **Media** bucket

### Step 2: Configure Bucket Settings

1. Click the **Settings** icon (gear) next to the bucket name
2. Make sure **Public bucket** is **ON** (toggle should be green)
3. Click **Save**

### Step 3: Add Storage Policies

1. Click **Policies** tab at the top
2. Click **New Policy**

#### Policy 1: Allow Public Uploads

```sql
Policy Name: Allow public uploads
Allowed operation: INSERT
Policy definition: true
```

Or use this SQL:
```sql
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'Media');
```

#### Policy 2: Allow Public Reads

```sql
Policy Name: Allow public reads
Allowed operation: SELECT
Policy definition: true
```

Or use this SQL:
```sql
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'Media');
```

#### Policy 3: Allow Public Updates

```sql
Policy Name: Allow public updates
Allowed operation: UPDATE
Policy definition: true
```

Or use this SQL:
```sql
CREATE POLICY "Allow public updates"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'Media')
WITH CHECK (bucket_id = 'Media');
```

#### Policy 4: Allow Public Deletes

```sql
Policy Name: Allow public deletes
Allowed operation: DELETE
Policy definition: true
```

Or use this SQL:
```sql
CREATE POLICY "Allow public deletes"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'Media');
```

---

## Quick Method: Use SQL Editor

1. Go to **SQL Editor** in Supabase Dashboard
2. Paste this entire script:

```sql
-- Enable RLS on storage.objects (if not already enabled)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow public uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public reads" ON storage.objects;
DROP POLICY IF EXISTS "Allow public updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow public deletes" ON storage.objects;

-- Create new policies for Media bucket
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'Media');

CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'Media');

CREATE POLICY "Allow public updates"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'Media')
WITH CHECK (bucket_id = 'Media');

CREATE POLICY "Allow public deletes"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'Media');
```

3. Click **Run** button
4. You should see: "Success. No rows returned"

---

## Test After Fixing

Run the test script again:

```bash
cd Essentials_construction_project/django-backend
python test_supabase_connection.py
```

Expected output:
```
✅ Connected to Supabase successfully
✅ Successfully accessed 'Media' bucket
✅ Successfully uploaded test file
✅ Successfully retrieved file URL
✅ Successfully deleted test file
```

---

## Security Note

These policies allow **anyone** with your anon key to upload files. This is okay because:

1. Your anon key is in your backend code (not exposed to users)
2. Only your Django backend uploads files (users don't upload directly)
3. Your Django backend validates authentication before uploading
4. The bucket is public for **reading** (so photos/documents can be viewed)

If you want more security, you can add authentication checks to the policies later.

---

## How File Organization Works

When files are uploaded, they're organized by type:

```
Media/
├── site_photos/
│   ├── site_123_morning_20260419_abc.jpg
│   └── site_123_evening_20260419_def.jpg
├── material_bills/
│   ├── bill_456_20260419_ghi.pdf
│   └── bill_456_20260419_ghi.jpg
├── vendor_bills/
│   └── bill_789_20260419_jkl.pdf
├── agreements/
│   └── agreement_101_20260419_mno.pdf
└── documents/
    └── doc_202_20260419_pqr.pdf
```

Each file has:
- Unique identifier (site ID, bill ID, etc.)
- Timestamp
- Random suffix for uniqueness
- Original file extension

---

## What Happens When Supervisor Uploads Photo

1. Supervisor clicks "Upload Morning Photo" in mobile app
2. Flutter app sends photo to Django backend: `POST /api/construction/sites/{id}/photos/`
3. Django backend:
   - Validates user is authenticated
   - Validates user is a supervisor
   - Validates site exists
   - Uploads photo to Supabase Storage: `Media/site_photos/site_123_morning_20260419_abc.jpg`
   - Saves photo URL in database table `api_sitephoto`
4. Photo is now accessible at: `https://ctwthgjuccioxivnzifb.supabase.co/storage/v1/object/public/Media/site_photos/site_123_morning_20260419_abc.jpg`
5. Accountant can view photo in their dashboard

---

## What Happens When Accountant Uploads Bill

1. Accountant uploads material bill with PDF in mobile app
2. Flutter app sends bill data + PDF to Django backend: `POST /api/accountant/material-bills/`
3. Django backend:
   - Validates user is authenticated
   - Validates user is an accountant
   - Uploads PDF to Supabase Storage: `Media/material_bills/bill_456_20260419_ghi.pdf`
   - Uploads photo (if any) to: `Media/material_bills/bill_456_20260419_ghi.jpg`
   - Saves bill data + file URLs in database table `api_materialbill`
4. Files are now accessible via URLs
5. Admin can view/download bills in their dashboard

---

## Database vs Storage

### Database (Supabase PostgreSQL)
Stores:
- User accounts (phone, role, name)
- Sites (name, location, budget)
- Entries (date, amount, description)
- Bill metadata (amount, vendor, date)
- Photo metadata (type, upload date)
- **File URLs** (links to files in storage)

### Storage (Supabase Storage)
Stores:
- Actual photo files (.jpg, .png)
- Actual document files (.pdf)
- Organized in folders by type

They work together:
```
Database record:
{
  "id": 123,
  "amount": 50000,
  "vendor": "ABC Suppliers",
  "bill_photo": "https://...supabase.co/storage/.../bill_123.jpg",
  "bill_document": "https://...supabase.co/storage/.../bill_123.pdf"
}

Storage files:
- Media/material_bills/bill_123.jpg
- Media/material_bills/bill_123.pdf
```

---

## Next Steps

1. ✅ Run the SQL script in Supabase Dashboard
2. ✅ Test connection: `python test_supabase_connection.py`
3. ✅ Update Render environment variables (if not done):
   - `SUPABASE_KEY` = your anon key
   - `SUPABASE_STORAGE_BUCKET` = Media
4. ✅ Push code to GitHub (already done)
5. ✅ Wait for Render deployment
6. ✅ Test photo upload in mobile app
7. ✅ Test document upload in mobile app

---

## Troubleshooting

### If test still fails:

1. **Check bucket name**: Must be exactly `Media` (case-sensitive)
2. **Check policies are created**: Go to Storage → Media → Policies tab
3. **Check bucket is public**: Storage → Media → Settings → Public bucket ON
4. **Try recreating bucket**: Delete and create new one with policies

### If uploads work locally but not on Render:

1. Check Render environment variables are set correctly
2. Check Render logs for errors: `https://dashboard.render.com/`
3. Redeploy manually if needed

---

## Summary

The issue is RLS (Row Level Security) blocking uploads. Fix by:
1. Making bucket public
2. Adding storage policies to allow uploads
3. Testing connection
4. Deploying to Render

After this, all photo and document uploads will work permanently!
