import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/construction_service.dart';

class SupervisorReportsScreen extends StatefulWidget {
  const SupervisorReportsScreen({super.key});

  @override
  State<SupervisorReportsScreen> createState() => _SupervisorReportsScreenState();
}

class _SupervisorReportsScreenState extends State<SupervisorReportsScreen> {
  final _constructionService = ConstructionService();
  
  List<Map<String, dynamic>> _sites = [];
  String? _selectedSiteId;
  
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _complaints = [];
  
  bool _isLoadingDocuments = false;
  bool _isLoadingComplaints = false;

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    try {
      final sites = await _constructionService.getSites();
      setState(() {
        _sites = sites;
      });
    } catch (e) {
      print('Error loading sites: $e');
    }
  }

  Future<void> _loadArchitectData() async {
    if (_selectedSiteId == null) return;
    
    setState(() {
      _isLoadingDocuments = true;
      _isLoadingComplaints = true;
    });

    try {
      // Load documents
      final docsResponse = await _constructionService.getArchitectDocuments(
        siteId: _selectedSiteId,
      );
      
      // Load complaints
      final complaintsResponse = await _constructionService.getArchitectComplaints(
        siteId: _selectedSiteId,
      );

      setState(() {
        _documents = List<Map<String, dynamic>>.from(docsResponse['documents'] ?? []);
        _complaints = List<Map<String, dynamic>>.from(complaintsResponse['complaints'] ?? []);
        _isLoadingDocuments = false;
        _isLoadingComplaints = false;
      });
    } catch (e) {
      print('Error loading architect data: $e');
      setState(() {
        _isLoadingDocuments = false;
        _isLoadingComplaints = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            color: const Color(0xFF1A1A2E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: const Color(0xFF1A1A2E)),
      ),
      body: Column(
        children: [
          // Site Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Site',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSiteId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on, color: const Color(0xFF1A1A2E), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: const Color(0xFF1A1A2E),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  isExpanded: true,
                  hint: const Text(
                    'Select a site',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  items: _sites.map((site) {
                    return DropdownMenuItem<String>(
                      value: site['id'] as String,
                      child: Text(
                        site['display_name'] as String? ?? site['site_name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSiteId = value);
                    _loadArchitectData();
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: const Color(0xFF1A1A2E)),
                  dropdownColor: Colors.white,
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _selectedSiteId == null
                ? _buildEmptyState()
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: const Color(0xFF6B7280).withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a site to view reports',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadArchitectData,
      color: const Color(0xFF1A1A2E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Documents Section
            _buildSectionHeader('Documents', Icons.description, _documents.length),
            const SizedBox(height: 12),
            _isLoadingDocuments
                ? _buildLoadingCard()
                : _documents.isEmpty
                    ? _buildEmptyCard('No documents uploaded yet')
                    : Column(
                        children: _documents.map((doc) => _buildDocumentCard(doc)).toList(),
                      ),
            
            const SizedBox(height: 24),
            
            // Complaints Section
            _buildSectionHeader('Complaints', Icons.report_problem, _complaints.length),
            const SizedBox(height: 12),
            _isLoadingComplaints
                ? _buildLoadingCard()
                : _complaints.isEmpty
                    ? _buildEmptyCard('No complaints reported yet')
                    : Column(
                        children: _complaints.map((complaint) => _buildComplaintCard(complaint)).toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1A1A2E), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final documentType = doc['document_type'] as String? ?? 'Unknown';
    final title = doc['title'] as String? ?? 'Untitled';
    final description = doc['description'] as String? ?? '';
    final uploadDate = doc['upload_date'] as String? ?? '';
    final architectName = doc['architect_name'] as String? ?? 'Unknown';
    final fileUrl = doc['file_url'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    documentType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.insert_drive_file,
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      architectName,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      uploadDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                if (fileUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Open file URL
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening: $fileUrl')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('View Document'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final title = complaint['title'] as String? ?? 'Untitled';
    final description = complaint['description'] as String? ?? '';
    final priority = complaint['priority'] as String? ?? 'Medium';
    final status = complaint['status'] as String? ?? 'Open';
    final uploadDate = complaint['upload_date'] as String? ?? '';
    final architectName = complaint['architect_name'] as String? ?? 'Unknown';

    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'resolved':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.report_problem,
                  color: priorityColor,
                  size: 20,
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      architectName,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      uploadDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280).withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
