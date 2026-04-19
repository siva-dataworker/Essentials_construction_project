# ⚠️ ACTION REQUIRED - Complete Supabase Storage Setup

## Code is pushed to GitHub ✅

Now you need to complete these 3 steps to make photos and documents work:

---

## Step 1: Get Supabase API Key (2 minutes)

1. Open: https://supabase.com/dashboard/project/ctwthgjuccioxivnzifb/settings/api
2. Scroll down to **Project API keys**
3. Copy the **anon public** key (long string starting with `eyJ...`)
4. Save it somewhere - you'll need it in Step 3

**Example of what it looks like:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODk1NzY4MDAsImV4cCI6MjAwNTE1MjgwMH0.xxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 2: Create Storage Bucket (2 minutes)

1. Open: https://supabase.com/dashboard/project/ctwthgjuccioxivnzifb/storage/buckets
2. Click **New bucket** button
3. Enter name: `construction-media`
4. **IMPORTANT**: Toggle **Public bucket** to ON (green)
5. Click **Create bucket**

**Why public?**
- Photos and documents need to be accessible via URL
- Your Django backend controls who can upload (only authenticated users)
- Anyone with the URL can view (which is what you want)

---

## Step 3: Add Environment Variables to Render (3 minutes)

1. Open: https://dashboard.render.com/web/srv-ctqvvvhu0jms73d8bnfg
2. Click **Environment** tab on the left
3. Click **Add Environment Variable** button
4. Add these 2 variables:

### Variable 1:
```
Key: SUPABASE_KEY
Value: (paste the key you copied in Step 1)
```

### Variable 2:
```
Key: SUPABASE_STORAGE_BUCKET
Value: construction-media
```

5. Click **Save Changes**

**Render will automatically redeploy** (takes 5-10 minutes)

---

## Step 4: Wait for Deployment (5-10 minutes)

1. Stay on Render dashboard
2. You'll see "Deploying..." status
3. Wait until it says "Live" (green)
4. Check the logs to make sure no errors

---

## Step 5: Test (2 minutes)

After deployment completes:

### Test 1: Upload Photo
1. Open your app
2. Login as Supervisor
3. Upload a morning photo
4. Go to Accountant view → Photos tab
5. Photo should display correctly ✅

### Test 2: Upload Document
1. Login as Accountant
2. Upload a material bill with PDF
3. Click to open the document
4. Should open correctly (no 404 error) ✅

### Test 3: Verify in Supabase
1. Go to: https://supabase.com/dashboard/project/ctwthgjuccioxivnzifb/storage/buckets/construction-media
2. You should see uploaded files in folders
3. Click on a file to preview it

---

## Total Time: ~15 minutes

---

## What Happens After Setup?

### Old files (uploaded before):
- ❌ Lost (they were on Render's temporary filesystem)
- Users need to re-upload important documents

### New files (uploaded after setup):
- ✅ Stored permanently in Supabase Storage
- ✅ Never get deleted
- ✅ Always accessible

---

## Troubleshooting

### If photos still don't load after setup:

1. **Check bucket is PUBLIC**:
   - Go to Supabase Storage
   - Click on `construction-media` bucket
   - Should have "Public" badge
   - If not, click settings and make it public

2. **Check Render environment variables**:
   - Go to Render dashboard → Environment
   - Verify both `SUPABASE_KEY` and `SUPABASE_STORAGE_BUCKET` are set
   - No typos in the values

3. **Check Render logs**:
   - Go to Render dashboard → Logs
   - Look for errors mentioning "supabase" or "storage"
   - If you see errors, share them with me

4. **Re-upload test files**:
   - Old files won't work
   - Upload new photos/documents to test

---

## Need Help?

If you get stuck on any step, let me know which step and what error you're seeing!

---

## Summary

✅ Code pushed to GitHub
⏳ Step 1: Get Supabase API key
⏳ Step 2: Create storage bucket
⏳ Step 3: Add to Render
⏳ Step 4: Wait for deployment
⏳ Step 5: Test

**Start with Step 1 now!**
