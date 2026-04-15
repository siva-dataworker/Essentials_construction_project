import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'site_engineer_photo_upload_screen.dart';
import 'site_photo_gallery_screen.dart';
import 'site_engineer_labour_screen.dart';
import 'site_engineer_history_screen.dart';

class SiteEngineerSiteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> site;
  final UserModel user;

  const SiteEngineerSiteDetailScreen({
    super.key,
    required this.site,
    required this.user,
  });

  @override
  State<SiteEngineerSiteDetailScreen> createState() => _SiteEngineerSiteDetailScreenState();
}

class _SiteEngineerSiteDetailScreenState extends State<SiteEngineerSiteDetailScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  List<Map<String, dynamic>> _extraCosts = [];
  bool _isLoadingExtraCosts = false;
  List<Map<String, dynamic>> _historyEntries = [];
  bool _isLoadingHistory = false;
  List<Map<String, dynamic>> _projectFiles = [];
  bool _isLoadingProjectFiles = false;

  @override
  void initState() {
    super.initState();
    _loadExtraCosts();
    _loadHistory();
    _loadProjectFiles();
  }

  Future<void> _loadProjectFiles() async {
    setState(() => _isLoadingProjectFiles = true);
    
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/project-files/${widget.site['id']}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _projectFiles = List<Map<String, dynamic>>.from(data['files']);
          _isLoadingProjectFiles = false;
        });
      } else {
        setState(() => _isLoadingProjectFiles = false);
      }
    } catch (e) {
      setState(() => _isLoadingProjectFiles = false);
    }
  }

  Future<void> _loadExtraCosts() async {
    setState(() => _isLoadingExtraCosts = true);
    
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/extra-costs/${widget.site['id']}/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _extraCosts = List<Map<String, dynamic>>.from(data['extra_costs']);
          _isLoadingExtraCosts = false;
        });
      } else {
        setState(() => _isLoadingExtraCosts = false);
      }
    } catch (e) {
      setState(() => _isLoadingExtraCosts = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    
    try {
      final token = await _authService.getToken();
      
      final response = await http.get(
        Uri.parse('${AuthService.baseUrl}/construction/accountant/all-entries/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final labourEntries = List<Map<String, dynamic>>.from(data['labour_entries'] ?? []);
        final materialEntries = List<Map<String, dynamic>>.from(data['material_entries'] ?? []);
        
        // Filter by current site
        final siteId = widget.site['id'].toString();
        final filteredLabour = labourEntries.where((e) => e['site_id'].toString() == siteId).toList();
        final filteredMaterial = materialEntries.where((e) => e['site_id'].toString() == siteId).toList();
        
        // Combine and sort by date
        final combined = <Map<String, dynamic>>[];
        
        for (var entry in filteredLabour) {
          combined.add({
            ...entry,
            'type': 'LABOUR',
          });
        }
        
        for (var entry in filteredMaterial) {
          combined.add({
            ...entry,
            'type': 'MATERIAL',
          });
        }
        
        // Sort by date (newest first)
        combined.sort((a, b) {
          final dateA = DateTime.tryParse(a['entry_time'] ?? a['updated_at'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['entry_time'] ?? b['updated_at'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
        
        setState(() {
          _historyEntries = combined;
          _isLoadingHistory = false;
        });
      } else {
        setState(() => _isLoadingHistory = false);
      }
    } catch (e) {
      setState(() => _isLoadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site Details',
          style: const TextStyle(
            color: const Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: const Color(0xFF1A1A2E)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildPhotosTab(),
          _buildComplaintsTab(),
          _buildProjectFilesTab(),
          _buildExtraCostTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: const Color(0xFF6B7280),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_camera),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Project Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Extra Cost',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickActions,
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.people,
                  label: 'Labour',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SiteEngineerLabourScreen(
                          siteId: widget.site['id'].toString(),
                          siteName: widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site',
                        ),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'History',
                  color: const Color(0xFF1A1A2E),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SiteEngineerHistoryScreen(
                          siteId: widget.site['id'].toString(),
                          siteName: widget.site['display_name'] ?? widget.site['site_name'] ?? 'Site',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Site Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF1A1A2E).withValues(alpha: 0.8), const Color(0xFF1A1A2E)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_city, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.site['display_name'] ?? widget.site['site_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.site['area'] ?? ''}, ${widget.site['street'] ?? ''}',
                            style: TextStyle(fontSize: 13, color: const Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Upload Photo Button
          ElevatedButton.icon(
            onPressed: () => _openPhotoUpload(),
            icon: const Icon(Icons.camera_alt, size: 20),
            label: const Text('Upload Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 12),

          // View Gallery Button
          OutlinedButton.icon(
            onPressed: () => _openPhotoGallery(),
            icon: const Icon(Icons.photo_library, size: 20),
            label: const Text('View Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A2E),
              side: const BorderSide(color: const Color(0xFF1A1A2E), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: const Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Photo Upload Guidelines',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildGuideline('🌅', 'Morning Photo', 'Upload before 1:00 PM - Work Started'),
                const SizedBox(height: 8),
                _buildGuideline('🌆', 'Evening Photo', 'Upload after 1:00 PM - Work Completed'),
                const SizedBox(height: 8),
                _buildGuideline('📸', 'Quality', 'Clear, well-lit photos of work progress'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideline(String icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplaintsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_problem_outlined, size: 80, color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Complaints',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(
              'View and resolve complaints raised by clients',
              style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF44336)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFilesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 80, color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'Project Files',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(
              'View and upload project documents and files',
              style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFF44336)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCostTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Add Extra Cost Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: () => _showAddExtraCostDialog(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Extra Cost', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: const Color(0xFF1A1A2E),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF1A1A2E),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Extra Costs'),
                Tab(text: 'History'),
              ],
            ),
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              children: [
                // Extra Costs List
                _isLoadingExtraCosts
                    ? const Center(child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)))
                    : _extraCosts.isEmpty
                        ? _buildEmptyExtraCostState()
                        : RefreshIndicator(
                            onRefresh: _loadExtraCosts,
                            color: const Color(0xFF1A1A2E),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _extraCosts.length,
                              itemBuilder: (context, index) => _buildExtraCostCard(_extraCosts[index]),
                            ),
                          ),
                
                // History View
                _buildHistoryView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)));
    }
    
    if (_historyEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 80, color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              const Text(
                'No History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 8),
              Text(
                'Labour and material entries will appear here',
                style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: const Color(0xFF1A1A2E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyEntries.length,
        itemBuilder: (context, index) => _buildHistoryCard(_historyEntries[index]),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final isLabour = entry['type'] == 'LABOUR';
    final icon = isLabour ? Icons.people : Icons.inventory_2;
    final color = isLabour ? const Color(0xFF4CAF50) : const Color(0xFF1A1A2E);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLabour ? entry['labour_type'] ?? 'Labour' : entry['material_type'] ?? 'Material',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLabour 
                            ? '${entry['labour_count']} workers'
                            : '${entry['quantity']} ${entry['unit'] ?? 'units'}',
                        style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    isLabour ? 'LABOUR' : 'MATERIAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            
            // Extra cost if present
            if (entry['extra_cost'] != null && entry['extra_cost'] > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF44336).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: const Color(0xFFF44336)),
                    const SizedBox(width: 6),
                    Text(
                      'Extra Cost: ₹${entry['extra_cost']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFF44336),
                      ),
                    ),
                    if (entry['extra_cost_notes'] != null && entry['extra_cost_notes'].toString().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry['extra_cost_notes'],
                          style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  entry['supervisor_name'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(entry['entry_time'] ?? entry['updated_at']),
                  style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyExtraCostState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 80, color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              'No Extra Costs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Extra Cost" to submit additional expenses',
              style: TextStyle(fontSize: 14, color: const Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraCostCard(Map<String, dynamic> cost) {
    final amount = cost['amount'] ?? 0;
    final status = cost['payment_status'] ?? 'PENDING';
    final statusColor = status == 'PAID' ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (cost['description'] != null && cost['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                cost['description'],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
            if (cost['notes'] != null && cost['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                cost['notes'],
                style: TextStyle(fontSize: 13, color: const Color(0xFF6B7280)),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  cost['submitted_by'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 4),
                Text(
                  _formatDate(cost['uploaded_at']),
                  style: TextStyle(fontSize: 12, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExtraCostDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final notesController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Add Extra Cost',
            style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Description *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Extra materials, Labor overtime',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Additional details...',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: const Color(0xFF6B7280))),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (amountController.text.isEmpty || descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in amount and description'),
                            backgroundColor: const Color(0xFFF44336),
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      try {
                        final token = await _authService.getToken();
                        
                        final response = await http.post(
                          Uri.parse('${AuthService.baseUrl}/construction/submit-extra-cost/'),
                          headers: {
                            'Authorization': 'Bearer $token',
                            'Content-Type': 'application/json',
                          },
                          body: json.encode({
                            'site_id': widget.site['id'],
                            'amount': amountController.text,
                            'description': descriptionController.text,
                            'notes': notesController.text,
                          }),
                        );

                        setState(() => isSubmitting = false);

                        if (response.statusCode == 201) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Extra cost submitted successfully!'),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                          _loadExtraCosts();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed: ${response.body}'),
                              backgroundColor: const Color(0xFFF44336),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: const Color(0xFFF44336),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _openPhotoUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteEngineerPhotoUploadScreen(site: widget.site),
      ),
    );
  }

  void _openPhotoGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SitePhotoGalleryScreen(site: widget.site),
      ),
    );
  }
}
