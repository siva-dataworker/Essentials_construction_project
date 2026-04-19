#!/usr/bin/env python3
"""
Test Supabase Storage connection
Run this to verify Supabase Storage is working
"""
import os
import sys
from decouple import config

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def test_supabase_connection():
    """Test if Supabase Storage is configured correctly"""
    
    print("=" * 60)
    print("SUPABASE STORAGE CONNECTION TEST")
    print("=" * 60)
    
    # Check environment variables
    print("\n1. Checking environment variables...")
    
    supabase_url = config('SUPABASE_URL', default='')
    supabase_key = config('SUPABASE_KEY', default='')
    supabase_bucket = config('SUPABASE_STORAGE_BUCKET', default='')
    
    if not supabase_url:
        print("❌ SUPABASE_URL not set")
        return False
    else:
        print(f"✅ SUPABASE_URL: {supabase_url}")
    
    if not supabase_key:
        print("❌ SUPABASE_KEY not set")
        print("   Go to Render dashboard and add SUPABASE_KEY environment variable")
        return False
    else:
        print(f"✅ SUPABASE_KEY: {supabase_key[:20]}...{supabase_key[-10:]}")
    
    if not supabase_bucket:
        print("❌ SUPABASE_STORAGE_BUCKET not set")
        print("   Go to Render dashboard and add SUPABASE_STORAGE_BUCKET=Media")
        return False
    else:
        print(f"✅ SUPABASE_STORAGE_BUCKET: {supabase_bucket}")
    
    # Check if supabase package is installed
    print("\n2. Checking if supabase package is installed...")
    try:
        from supabase import create_client
        print("✅ supabase package is installed")
    except ImportError:
        print("❌ supabase package not installed")
        print("   Run: pip install supabase storage3")
        return False
    
    # Try to connect to Supabase
    print("\n3. Testing connection to Supabase...")
    try:
        supabase = create_client(supabase_url, supabase_key)
        print("✅ Connected to Supabase successfully")
    except Exception as e:
        print(f"❌ Failed to connect to Supabase: {e}")
        return False
    
    # Try to access storage bucket
    print(f"\n4. Testing access to '{supabase_bucket}' bucket...")
    try:
        # List files in bucket (should work even if empty)
        files = supabase.storage.from_(supabase_bucket).list()
        print(f"✅ Successfully accessed '{supabase_bucket}' bucket")
        print(f"   Files in bucket: {len(files)}")
    except Exception as e:
        print(f"❌ Failed to access bucket: {e}")
        print(f"   Make sure '{supabase_bucket}' bucket exists in Supabase Storage")
        print(f"   Go to: https://supabase.com/dashboard/project/ctwthgjuccioxivnzifb/storage/buckets")
        return False
    
    # Try to upload a test file
    print("\n5. Testing file upload...")
    try:
        test_content = b"Test file from Django backend"
        test_path = "test/connection_test.txt"
        
        supabase.storage.from_(supabase_bucket).upload(
            path=test_path,
            file=test_content,
            file_options={"content-type": "text/plain"}
        )
        print(f"✅ Successfully uploaded test file to {test_path}")
        
        # Get public URL
        public_url = supabase.storage.from_(supabase_bucket).get_public_url(test_path)
        print(f"   Public URL: {public_url}")
        
        # Clean up test file
        supabase.storage.from_(supabase_bucket).remove([test_path])
        print(f"✅ Test file cleaned up")
        
    except Exception as e:
        print(f"❌ Failed to upload test file: {e}")
        return False
    
    print("\n" + "=" * 60)
    print("✅ ALL TESTS PASSED!")
    print("=" * 60)
    print("\nSupabase Storage is configured correctly and ready to use.")
    print("Photos and documents will now be stored in Supabase Storage.")
    return True

if __name__ == '__main__':
    success = test_supabase_connection()
    sys.exit(0 if success else 1)
