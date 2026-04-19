# Document Upload Issue - FIXED ✅

## Problem

When clicking on bills/agreements in the mobile app, you got error: "Could not open document"

## Root Cause

The Flutter app was incorrectly handling Supabase Storage URLs:

### Before (BROKEN):
```dart
final url = 'https://new-essentials.onrender.com$fileUrl';
```

This created invalid URLs like:
```
https://new-essentials.onrender.com/https://ctwthgjuccioxivnzifb.supabase.co/storage/v1/object/public/Media/material_bills/file.pdf
```

### After (FIXED):
```dart
final url = fileUrl.startsWith('http') 
    ? fileUrl 
    : 'https://new-essentials.onrender.com$fileUrl';
```

Now it correctly uses:
- Absolute URLs (Supabase Storage): `https://ctwthgjuccioxivnzifb.supabase.co/storage/...`
- Relative URLs (old system): `https://new-essentials.onrender.com/media/...`

---

## What Was Fixed

### Files Updated:
1. `otp_phone_auth/lib/screens/accountant_bills_screen.dart`
2. `otp_phone_auth/lib/screens/accountant_entry_screen.dart`

### Changes:
- Modified `_openDocument()` function to detect if URL is absolute (starts with 'http')
- If absolute: Use URL directly (Supabase Storage)
- If relative: Prepend Render URL (old system)

---

## Next Steps

### 1. Update Render Environment Variables

Go to https://dashboard.render.com/ and update:

```
SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0d3RoZ2p1Y2Npb3hpdm56aWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNzQzODAsImV4cCI6MjA4MTY1MDM4MH0.xtE4a1nn-sDTe-HWMkJS-RA_ndahMy1iKUjG6dXE_RY

SUPABASE_STORAGE_BUCKET = Media
```

Wait 5-10 minutes for Render to redeploy.

### 2. Rebuild Flutter App

The Flutter code has been updated and pushed to GitHub. You need to rebuild the app:

#### For Android:
```bash
cd Essentials_construction_project/otp_phone_auth
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

#### For iOS (if needed):
```bash
flutter build ios --release
```

### 3. Install Updated App

- Transfer the new APK to your phone
- Install it (uninstall old version first if needed)
- Test document uploads

---

## Testing After Fix

### Test 1: Upload New Material Bill
1. Login as Accountant
2. Go to Bills & Agreements
3. Click "Add Bill/Agreement"
4. Fill in material bill details
5. Attach a PDF document
6. Submit
7. Click on the bill to open document
8. ✅ Document should open correctly

### Test 2: Upload New Agreement
1. Login as Accountant
2. Go to Bills & Agreements → Agreements tab
3. Click "Add Bill/Agreement"
4. Fill in agreement details
5. Attach a PDF document
6. Submit
7. Click on the agreement to open document
8. ✅ Document should open correctly

### Test 3: Verify in Supabase
1. Go to Supabase Dashboard → Storage → Media bucket
2. Check folders:
   - `material_bills/` - Should have bill PDFs
   - `vendor_bills/` - Should have vendor bill PDFs
   - `site_agreements/` - Should have agreement PDFs
3. ✅ Files should be visible in bucket

---

## How It Works Now

### Upload Flow:
```
1. Accountant uploads bill with PDF in mobile app
   ↓
2. Flutter app sends to Django backend: POST /api/construction/upload-material-bill/
   ↓
3. Django backend uploads PDF to Supabase Storage
   ↓
4. Supabase returns URL: https://ctwthgjuccioxivnzifb.supabase.co/storage/v1/object/public/Media/material_bills/20260419_abc123.pdf
   ↓
5. Django saves bill data + file URL in database
   ↓
6. Flutter app receives response with file_url
```

### View Flow:
```
1. Accountant clicks on bill to view document
   ↓
2. Flutter app checks if file_url starts with 'http'
   ↓
3. If yes: Use URL directly (Supabase Storage)
   ↓
4. Opens document in external app (PDF viewer, browser, etc.)
```

---

## File Organization in Supabase Storage

```
Media/
├── site_photos/
│   ├── 20260419_213619_abc123.jpg (Supervisor photos)
│   └── ...
├── material_bills/
│   ├── 20260419_140522_def456.pdf (Material bill documents)
│   ├── 20260419_140522_def456.jpg (Material bill photos)
│   └── ...
├── vendor_bills/
│   ├── 20260419_153045_ghi789.pdf (Vendor bill documents)
│   └── ...
├── site_agreements/
│   ├── 20260419_160130_jkl012.pdf (Agreement documents)
│   └── ...
└── documents/
    ├── 20260419_171520_mno345.pdf (Other documents)
    └── ...
```

---

## Advantages of Supabase Storage

1. ✅ **Permanent Storage**: Files never get deleted (unlike Render's ephemeral filesystem)
2. ✅ **Fast Access**: CDN-backed, files load quickly
3. ✅ **Organized**: Files are organized in folders by type
4. ✅ **Secure**: Row Level Security policies control access
5. ✅ **Free Tier**: 1 GB storage (plenty for your project)
6. ✅ **Easy Management**: View/delete files in Supabase Dashboard

---

## Troubleshooting

### If documents still don't open after rebuild:

1. **Check you installed the NEW APK**:
   - Build date should be today
   - Version should be updated

2. **Check Render environment variables**:
   - Go to Render Dashboard → Environment
   - Verify `SUPABASE_KEY` and `SUPABASE_STORAGE_BUCKET` are set
   - Redeploy if needed

3. **Check Supabase bucket**:
   - Go to Supabase Dashboard → Storage → Media
   - Should be PUBLIC
   - Should have 4 policies (INSERT, SELECT, UPDATE, DELETE)

4. **Check file URL format**:
   - Open bill in app
   - Check logs/network tab
   - file_url should start with: `https://ctwthgjuccioxivnzifb.supabase.co/storage/...`

5. **Re-upload test document**:
   - Old documents won't work (they were on Render's filesystem)
   - Upload a NEW document to test
   - Should work correctly

---

## Summary

✅ Flutter code fixed to handle Supabase Storage URLs
✅ Changes pushed to GitHub
✅ Backend already uses Supabase Storage correctly
✅ Test scripts confirm uploads work locally

Next steps:
1. Update Render environment variables
2. Rebuild Flutter app
3. Install new APK
4. Test document uploads

After this, all documents will be stored permanently and accessible!
