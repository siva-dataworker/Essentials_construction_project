# Run App Locally for Development

## Current Issue:
Kotlin cache corruption due to different drive letters (C:\ vs E:\)

## Solution: Move Project to C:\ Drive

### Step 1: Copy Project to C:\ Drive

Open PowerShell and run:

```powershell
# Create directory on C:\
New-Item -ItemType Directory -Path "C:\Projects" -Force

# Copy entire project
xcopy "E:\const_proj\Essentials_construction_project" "C:\Projects\Essentials_construction_project" /E /I /H /Y

# Verify copy
cd C:\Projects\Essentials_construction_project
dir
```

### Step 2: Open in VS Code

```powershell
cd C:\Projects\Essentials_construction_project
code .
```

### Step 3: Clean and Setup Flutter

```powershell
cd C:\Projects\Essentials_construction_project\otp_phone_auth
flutter clean
flutter pub get
```

### Step 4: Run on Phone

```powershell
flutter run
```

## Alternative: Run Without Moving (Try First)

Sometimes a simple restart fixes it:

```powershell
cd E:\const_proj\Essentials_construction_project\otp_phone_auth

# Stop Gradle daemon
cd android
./gradlew --stop

# Clean everything
cd ..
flutter clean
flutter pub cache clean
flutter pub get

# Try running
flutter run
```

## For Development Workflow:

### Hot Reload (Fast):
- Make code changes
- Press `r` in terminal (hot reload)
- Changes appear instantly

### Hot Restart (Medium):
- Press `R` in terminal
- Restarts app with changes

### Full Rebuild (Slow):
- Press `q` to quit
- Run `flutter run` again

## Backend Setup:

Your app is currently pointing to Render:
```
https://essentials-construction-project.onrender.com
```

### To Use Local Backend:

1. **Start Django backend:**
   ```powershell
   cd C:\Projects\Essentials_construction_project\django-backend
   python manage.py runserver 192.168.1.9:8000
   ```

2. **Update Flutter to use local backend:**
   - Open all service files
   - Change URL from Render to local:
   ```dart
   // Change from:
   static const String baseUrl = 'https://essentials-construction-project.onrender.com/api';
   
   // To:
   static const String baseUrl = 'http://192.168.1.9:8000/api';
   ```

3. **Hot restart app** to use local backend

## Recommended Setup:

### For Development:
- Backend: Local (192.168.1.9:8000)
- Flutter: Run on phone via USB
- Fast iteration with hot reload

### For Testing:
- Backend: Render (production)
- Flutter: Build APK via Codemagic
- Test real-world scenario

## Quick Commands:

```powershell
# Check devices
flutter devices

# Run on specific device
flutter run -d ZN42279PDM  # Your moto g45

# Run on Windows
flutter run -d windows

# Run on Chrome
flutter run -d chrome

# Clean build
flutter clean && flutter pub get && flutter run

# View logs
flutter logs
```

## Troubleshooting:

### If build still fails:
1. Restart computer
2. Move project to C:\
3. Clear all caches
4. Try again

### If app crashes:
- Check backend is running
- Check phone is on same WiFi
- Check URL in service files

### If changes don't appear:
- Try hot restart (R)
- Try full rebuild (q then flutter run)

## Development Tips:

1. **Use Hot Reload** - Fastest way to see changes
2. **Keep Backend Running** - Start once, use all day
3. **Use VS Code Terminal** - See logs in real-time
4. **Test on Real Device** - More accurate than emulator

Your phone is connected and ready! Just need to fix the Kotlin cache issue.
