"""
Supabase Storage utility for uploading files (photos, documents)
"""
from supabase import create_client, Client
from django.conf import settings
import uuid
import os
from datetime import datetime

class SupabaseStorage:
    def __init__(self):
        self.supabase: Client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_KEY
        )
        self.bucket = settings.SUPABASE_STORAGE_BUCKET
    
    def upload_file(self, file, folder='uploads'):
        """
        Upload a file to Supabase Storage
        
        Args:
            file: Django UploadedFile object
            folder: Folder name in bucket (e.g., 'site_photos', 'material_bills')
        
        Returns:
            dict: {'success': bool, 'url': str, 'path': str, 'error': str}
        """
        try:
            # Generate unique filename
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            unique_id = str(uuid.uuid4())[:8]
            file_ext = os.path.splitext(file.name)[1]
            filename = f"{timestamp}_{unique_id}{file_ext}"
            
            # Full path in bucket
            file_path = f"{folder}/{filename}"
            
            # Read file content
            file_content = file.read()
            
            # Upload to Supabase Storage
            response = self.supabase.storage.from_(self.bucket).upload(
                path=file_path,
                file=file_content,
                file_options={"content-type": file.content_type}
            )
            
            # Get public URL
            public_url = self.supabase.storage.from_(self.bucket).get_public_url(file_path)
            
            return {
                'success': True,
                'url': public_url,
                'path': file_path,
                'filename': filename
            }
        
        except Exception as e:
            print(f"Error uploading to Supabase Storage: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def delete_file(self, file_path):
        """
        Delete a file from Supabase Storage
        
        Args:
            file_path: Path to file in bucket
        
        Returns:
            dict: {'success': bool, 'error': str}
        """
        try:
            self.supabase.storage.from_(self.bucket).remove([file_path])
            return {'success': True}
        except Exception as e:
            print(f"Error deleting from Supabase Storage: {e}")
            return {'success': False, 'error': str(e)}
    
    def get_public_url(self, file_path):
        """
        Get public URL for a file
        
        Args:
            file_path: Path to file in bucket
        
        Returns:
            str: Public URL
        """
        try:
            return self.supabase.storage.from_(self.bucket).get_public_url(file_path)
        except Exception as e:
            print(f"Error getting public URL: {e}")
            return None


# Singleton instance
storage = SupabaseStorage()
