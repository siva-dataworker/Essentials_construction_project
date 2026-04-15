# Final Solution: Run App Locally for Development

## Problem:
Kotlin compiler cache corruption on Windows due to different drive letters.

## ✅ WORKING SOLUTION: Move Project to C:\ Drive

This is the ONLY reliable solution for this Windows-specific issue.

### Why This Works:
- Pub cache: `C:\Users\Admin\AppData\Local\Pub\Cache\`
- Project needs to be on same drive: `C:\`
- Kotlin compiler can then resolve paths correctly

## Step-by-Step Instructions:

### 1. Copy Project to C:\ Drive

Open PowerShell as Administrator and run:

```powershell
# Create Projects folder on C:\
New-Item -ItemType Directory -Path "C:\Projects" -Force

# Copy entire project (takes 2-3 minutes)
xcopy "E:\const_proj\Essentials_construction_project" "C:\Projects\Essentials_construction_project" /E /I /H /Y

# Verify copy completed
cd C:\Projects\Essentials_construction_project
dir
```

### 2. Open Project in VS Code

```powershell
# Close current VS Code window first!
# Then open new location:
code C:\Projects\Essentials_construction_project
```

### 3. Setup Flutter

```powershell
cd C:\Projects\Essentials_construction_project\otp_phone_auth

# Clean everything
flutter clean

# Get dependencies
flutter pub get
```

### 4. Run on Phone

```powershell
# Make sure phone is connected
flutter devices

# Run app
flutter run
```

This should work without the Kotlin cache error!

## Development Workflow:

### Daily Development:
1. **Start Backend** (if using local):
   ```powershell
   cd C:\Projects\Essentials_construction_project\django-backend
   python manage.py runserver 192.168.1.9:8000
   ```

2. **Run Flutter App**:
   ```powershell
   cd C:\Projects\Essentials_construction_project\otp_phone_auth
   flutter run
   ```

3. **Make Changes**:
   - Edit code in VS Code
   - Press `r` for hot reload (instant)
   - Press `R` for hot restart (quick)
   - Press `q` to quit

### Hot Reload Commands:
- `r` - Hot reload (fastest, preserves state)
- `R` - Hot restart (quick, resets state)
- `q` - Quit app
- `d` - Detach (app keeps running)
- `h` - Help

## Backend Configuration:

### Option A: Use Render Backend (Current)
- No setup needed
- App already configured
- URL: `https://essentials-construction-project.onrender.com`
- ✅ Recommended for development

### Option B: Use Local Backend
If you want to test backend changes:

1. **Update service files** to use local IP:
   ```dart
   static const String baseUrl = 'http://192.168.1.9:8000/api';
   ```

2. **Start Django backend**:
   ```powershell
   cd C:\Projects\Essentials_construction_project\django-backend
   python manage.py runserver 192.168.1.9:8000
   ```

3. **Hot restart app** (press `R`)

## Testing on Different Platforms:

### On Phone (Recommended):
```powershell
flutter run -d ZN42279PDM
```

### On Windows Desktop:
```powershell
flutter run -d windows
```

### On Chrome Browser:
```powershell
flutter run -d chrome
```

## Common Development Tasks:

### View Logs:
```powershell
flutter logs
```

### Check for Errors:
```powershell
flutter analyze
```

### Format Code:
```powershell
flutter format lib/
```

### Update Dependencies:
```powershell
flutter pub get
```

### Clean Build:
```powershell
flutter clean && flutter pub get
```

## Troubleshooting:

### If Build Fails:
1. Stop Gradle daemon:
   ```powershell
   cd android
   ./gradlew --stop
   cd ..
   ```

2. Clean and rebuild:
   ```powershell
   flutter clean
   flutter pub get
   flutter run
   ```

### If App Crashes:
- Check backend is running
- Check phone is on same WiFi (if using local backend)
- Check logs: `flutter logs`

### If Changes Don't Appear:
- Try hot restart: Press `R`
- Try full rebuild: Press `q` then `flutter run`

## Git Workflow:

### After Moving to C:\:

1. **Check status**:
   ```powershell
   cd C:\Projects\Essentials_construction_project
   git status
   ```

2. **Make changes and commit**:
   ```powershell
   git add .
   git commit -m "Your message"
   git push
   ```

3. **Pull latest changes**:
   ```powershell
   git pull
   ```

## Performance Tips:

1. **Use Hot Reload** - Fastest way to see changes (press `r`)
2. **Keep App Running** - Don't quit unless necessary
3. **Use Real Device** - Faster than emulator
4. **Close Unused Apps** - Free up system resources

## Summary:

✅ **Move project to C:\ drive** - Solves Kotlin cache issue
✅ **Use Render backend** - No local backend setup needed
✅ **Hot reload for development** - Fast iteration
✅ **Build APK on Codemagic** - For distribution

## Quick Reference:

```powershell
# Copy project to C:\
xcopy "E:\const_proj\Essentials_construction_project" "C:\Projects\Essentials_construction_project" /E /I /H /Y

# Open in VS Code
code C:\Projects\Essentials_construction_project

# Run app
cd C:\Projects\Essentials_construction_project\otp_phone_auth
flutter clean
flutter pub get
flutter run

# Hot reload: Press 'r'
# Hot restart: Press 'R'
# Quit: Press 'q'
```

This is the definitive solution for local development on Windows!
