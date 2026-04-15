import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/document_service.dart';
import '../utils/app_colors.dart';

class SiteEngineerDocumentScreen extends StatefulWidget {
  final String siteId;
  final String siteName;

  const SiteEngineerDocumentScreen({
    super.key,
    required this.siteId,
    required this.siteName,
  });

  @override
  State<SiteEngineerDocumentScreen> createState() => _SiteEngineerDocumentScreenState();
}

class _SiteEngineerDocumentScreenState extends State<SiteEngineerDocumentScreen> {
  final _documentService = DocumentService();
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _isLoading = true);
    
    final result = await _documentService.getSiteEngineerDocuments(
      siteId: widget.siteId,
    );
    
    if (result['success'] == true) {
      setState(() {
        _documents = result['documents'];
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _uploadDocument() async {
    showDialog(
      context: context,
      builder: (context) => _DocumentUploadDialog(
        siteId: widget.siteId,
        siteName: widget.siteName,
        onSuccess: () {
          _loadDocuments();
        },
      ),
    );
  }

  Future<void> _openDocument(String fileUrl) async {
    final url = 'http://192.168.1.9:8000$fileUrl';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('Documents - ${widget.siteName}'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)))
          : _documents.isEmpty
              ? _buildEmptyState()
              : _buildDocumentList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload PDF'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, size: 80, color: const Color(0xFF6B7280)),
          const SizedBox(height: 16),
          const Text(
            'No Documents Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload site plans and floor designs',
            style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _uploadDocument,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload First Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList() {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      color: const Color(0xFF1A1A2E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final doc = _documents[index];
          return _buildDocumentCard(doc);
        },
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final fileSize = doc['file_size'] != null 
        ? '${(doc['file_size'] / 1024 / 1024).toStringAsFixed(2)} MB'
        : 'Unknown size';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDocument(doc['file_url']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doc['document_type'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc['upload_date'] ?? '',
                        style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                      ),
                      Text(
                        fileSize,
                        style: TextStyle(fontSize: 11, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadDialog extends StatefulWidget {
  final String siteId;
  final String siteName;
  final VoidCallback onSuccess;

  const _DocumentUploadDialog({
    required this.siteId,
    required this.siteName,
    required this.onSuccess,
  });

  @override
  State<_DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<_DocumentUploadDialog> {
  final _documentService = DocumentService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Site Plan';
  File? _selectedFile;
  bool _isUploading = false;

  final List<String> _documentTypes = [
    'Site Plan',
    'Floor Design',
    'Structural Plan',
    'Electrical Plan',
    'Plumbing Plan',
    'HVAC Plan',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _upload() async {
    // Validate inputs
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter a title for the document'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please select a PDF file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    final result = await _documentService.uploadSiteEngineerDocument(
      siteId: widget.siteId,
      documentType: _selectedType,
      title: _titleController.text,
      description: _descriptionController.text,
      file: _selectedFile!,
    );

    setState(() => _isUploading = false);

    if (mounted) {
      if (result['success'] == true) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Document uploaded successfully!'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['error']}'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.siteName,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                ),
                items: _documentTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Title *',
                  hintText: 'e.g., Main Site Layout, Ground Floor Plan',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                  helperText: 'Required - Enter a descriptive title',
                  helperStyle: const TextStyle(color: Colors.red, fontSize: 11),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: Text(_selectedFile == null ? 'Select PDF File *' : 'PDF Selected'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedFile!.path.split('/').last,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isUploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Upload'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
