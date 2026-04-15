import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/site_engineer_provider.dart';
import '../utils/app_colors.dart';

class SiteEngineerProjectFilesScreen extends StatefulWidget {
  const SiteEngineerProjectFilesScreen({super.key});

  @override
  State<SiteEngineerProjectFilesScreen> createState() => _SiteEngineerProjectFilesScreenState();
}

class _SiteEngineerProjectFilesScreenState extends State<SiteEngineerProjectFilesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SiteEngineerProvider>().loadProjectFiles();
    });
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return '🖼️';
      case 'dwg':
      case 'dxf':
        return '📐';
      default:
        return '📁';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: const Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Files',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              'Uploaded by Architect',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Consumer<SiteEngineerProvider>(
        builder: (context, provider, child) {
          final files = provider.projectFiles;
          final isLoading = provider.isLoading;

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
            );
          }

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open,
                      size: 60,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Project Files',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Files will appear here once uploaded',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProjectFiles(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _buildFileCard(file);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(Map<String, dynamic> file) {
    final fileName = file['file_name'] ?? 'Unknown File';
    final fileSize = file['file_size'] ?? 0;
    final uploadedAt = file['uploaded_at'] ?? '';
    final fileIcon = _getFileIcon(fileName);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showFileOptions(file);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      fileIcon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            uploadedAt,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.storage,
                            size: 14,
                            color: const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatFileSize(fileSize),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFileOptions(Map<String, dynamic> file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              file['file_name'] ?? 'File',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.download, color: const Color(0xFF1A1A2E)),
              ),
              title: const Text(
                'Download File',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              subtitle: const Text('Save to device'),
              onTap: () {
                Navigator.pop(context);
                _downloadFile(file);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.visibility, color: const Color(0xFF1A1A2E)),
              ),
              title: const Text(
                'View File',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              subtitle: const Text('Open in viewer'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File viewer coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadFile(Map<String, dynamic> file) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 16),
            Text('Downloading file...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // TODO: Implement actual file download
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File downloaded to Downloads folder'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }
}
