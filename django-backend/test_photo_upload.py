"""
Test photo upload to Supabase Storage
"""
import os
import sys
from pathlib import Path
from io import BytesIO
from PIL import Image

# Add project to path
sys.path.insert(0, str(Path(__file__).parent))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
import django
django.setup()

from api.supabase_storage import storage
from django.core.files.uploadedfile import SimpleUploadedFile

print("=" * 60)
print("TESTING PHOTO UPLOAD TO SUPABASE STORAGE")
print("=" * 60)

# Create a test image
print("\n1. Creating test image...")
img = Image.new('RGB', (100, 100), color='red')
img_bytes = BytesIO()
img.save(img_bytes, format='JPEG')
img_bytes.seek(0)

# Create Django UploadedFile
test_photo = SimpleUploadedFile(
    name='test_photo.jpg',
    content=img_bytes.read(),
    content_type='image/jpeg'
)
print(f"✅ Created test image: {test_photo.name} ({test_photo.size} bytes)")

# Test upload
print("\n2. Uploading to Supabase Storage...")
print(f"   Bucket: {storage.bucket}")
print(f"   Folder: site_photos")

result = storage.upload_file(test_photo, folder='site_photos')

print("\n3. Upload Result:")
if result['success']:
    print(f"✅ Upload successful!")
    print(f"   URL: {result['url']}")
    print(f"   Path: {result['path']}")
    print(f"   Filename: {result['filename']}")
    
    print("\n4. Verifying file in bucket...")
    # List files in bucket
    try:
        files = storage.supabase.storage.from_(storage.bucket).list('site_photos')
        print(f"✅ Files in site_photos folder: {len(files)}")
        for f in files:
            print(f"   - {f['name']}")
    except Exception as e:
        print(f"❌ Error listing files: {e}")
    
    print("\n5. Cleaning up test file...")
    delete_result = storage.delete_file(result['path'])
    if delete_result['success']:
        print("✅ Test file deleted")
    else:
        print(f"❌ Failed to delete: {delete_result.get('error')}")
else:
    print(f"❌ Upload failed: {result.get('error')}")

print("\n" + "=" * 60)
print("TEST COMPLETE")
print("=" * 60)
