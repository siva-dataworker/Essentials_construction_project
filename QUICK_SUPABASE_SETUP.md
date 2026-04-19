# Quick Setup Guide - Supabase Storage

## What You Need to Do (5 minutes)

### Step 1: Get Your Supabase API Key

1. Go to: https://supabase.com/dashboard/project/ctwthgjuccioxivnzifb
2. Click **Settings** (gear icon) → **API**
3. Copy the **anon public** key (long string starting with `eyJ...`)

### Step 2: Create Storage Bucket

1. In Supabase, click **Storage** (left sidebar)
2. Click **New bucket**
3. Name: `construction-media`
4. Toggle **Public bucket** ON
5. Click **Create**

### Step 3: Add to Render

1. Go to: https://dashboard.render.com/
2. Click your service: `new-essentials`
3. Go to **Environment** tab
4. Add these 2 variables:

```
SUPABASE_KEY = (paste your key from Step 1)
SUPABASE_STORAGE_BUCKET = construction-media
```

5. Click **Save Changes** (Render will redeploy automatically)

### Step 4: Push Code

```bash
cd Essentials_construction_project
git add -A
git commit -m "Setup Supabase Storage"
git push origin main
```

## That's It!

After Render redeploys (5-10 min), photos and documents will work!

## Test

1. Upload a photo as Supervisor
2. View it in Accountant screen
3. Should display correctly now!
