# Setup Cloudinary for Media Files (Photos & Documents)

## Problem

Render's filesystem is **ephemeral** - any uploaded files (photos, PDFs, documents) are deleted when the server restarts or redeploys. This is why photos and documents are not loading.

## Solution

Use **Cloudinary** (free tier) to store all media files in the cloud.

---

## Step 1: Create Cloudinary Account

1. Go to: https://cloudinary.com/users/register_free
2. Sign up for a FREE account
3. Verify your email
4. Login to Cloudinary Dashboard

---

## Step 2: Get Cloudinary Credentials

1. Go to: https://cloudinary.com/console
2. You'll see your credentials on the dashboard:
   - **Cloud Name**: (e.g., `dxyz123abc`)
   - **API Key**: (e.g., `123456789012345`)
   - **API Secret**: (e.g., `abcdefghijklmnopqrstuvwxyz123`)

3. Copy these values - you'll need them in the next step

---

## Step 3: Update Render Environment Variables

1. Go to: https://dashboard.render.com/
2. Click on your backend service: `new-essentials`
3. Go to **Environment** tab
4. Add these 3 new environment variables:

```
CLOUDINARY_CLOUD_NAME = your_cloud_name_here
CLOUDINARY_API_KEY = your_api_key_here
CLOUDINARY_API_SECRET = your_api_secret_here
```

5. Click **Save Changes**
6. Render will automatically redeploy your service

---

## Step 4: Update Local .env File (Optional - for local testing)

Edit `Essentials_construction_project/django-backend/.env`:

```env
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name_here
CLOUDINARY_API_KEY=your_api_key_here
CLOUDINARY_API_SECRET=your_api_secret_here
```

---

## Step 5: Push Changes to GitHub

The code changes have already been made:
- ✅ Added `cloudinary` and `django-cloudinary-storage` to requirements.txt
- ✅ Added cloudinary apps to INSTALLED_APPS
- ✅ Configured DEFAULT_FILE_STORAGE to use Cloudinary
- ✅ Added cloudinary config in settings.py

Now push to GitHub:

```bash
cd Essentials_construction_project
git add -A
git commit -m "Add Cloudinary for persistent media storage"
git push origin main
```

---

## Step 6: Wait for Render to Deploy

1. Render will automatically detect the push
2. It will install new dependencies (cloudinary)
3. It will restart with new environment variables
4. This takes about 5-10 minutes

---

## Step 7: Test

After deployment completes:

### Test Photo Upload:
1. Login as Supervisor
2. Upload a morning/evening photo
3. Go to Accountant view
4. Check if photo displays correctly

### Test Document Upload:
1. Login as Accountant
2. Upload a material bill with PDF
3. Click to open the document
4. Should open correctly (no 404 error)

### Verify in Cloudinary:
1. Go to: https://cloudinary.com/console/media_library
2. You should see uploaded files there
3. Files are organized by folder (e.g., `site_photos/`, `material_bills/`)

---

## How It Works

### Before (Render Filesystem - BROKEN):
```
User uploads photo → Saved to /opt/render/project/media/ → Server restarts → Files deleted ❌
```

### After (Cloudinary - WORKING):
```
User uploads photo → Uploaded to Cloudinary cloud → Stored permanently → Always accessible ✅
```

### URL Changes:
- **Before**: `https://new-essentials.onrender.com/media/photo.jpg` (404 error)
- **After**: `https://res.cloudinary.com/your_cloud_name/image/upload/photo.jpg` (works!)

---

## Cloudinary Free Tier Limits

- ✅ 25 GB storage
- ✅ 25 GB bandwidth/month
- ✅ Unlimited transformations
- ✅ Perfect for this project!

---

## Troubleshooting

### If photos still don't load after setup:

1. **Check Render Environment Variables**:
   - Go to Render dashboard
   - Verify all 3 Cloudinary variables are set
   - Make sure there are no typos

2. **Check Render Logs**:
   ```
   Go to Render dashboard → Your service → Logs
   Look for errors like "cloudinary" or "media"
   ```

3. **Re-upload Test Files**:
   - Old files uploaded before Cloudinary won't work
   - Upload new photos/documents to test
   - These will go to Cloudinary

4. **Verify Cloudinary Dashboard**:
   - Login to Cloudinary
   - Go to Media Library
   - You should see uploaded files

---

## Migration Note

**Important**: Files uploaded BEFORE setting up Cloudinary are lost (they were on Render's ephemeral filesystem). Users will need to re-upload:
- Supervisor photos
- Material bills
- Vendor bills
- Agreements
- Site engineer documents
- Architect documents

This is a one-time migration. After Cloudinary is set up, all files will be stored permanently.

---

## Next Steps

1. ✅ Create Cloudinary account
2. ✅ Get credentials from dashboard
3. ✅ Add environment variables to Render
4. ✅ Push code changes to GitHub
5. ✅ Wait for Render deployment
6. ✅ Test photo and document uploads
7. ✅ Inform users to re-upload important documents

---

## Support

If you need help:
- Cloudinary Docs: https://cloudinary.com/documentation/django_integration
- Render Docs: https://render.com/docs/environment-variables
