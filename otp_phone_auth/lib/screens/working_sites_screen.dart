import 'package:flutter/material.dart';
import '../services/construction_service.dart';
import '../utils/app_colors.dart';
import 'site_detail_screen.dart';

class WorkingSitesScreen extends StatefulWidget {
  const WorkingSitesScreen({super.key});

  @override
  State<WorkingSitesScreen> createState() => _WorkingSitesScreenState();
}

class _WorkingSitesScreenState extends State<WorkingSitesScreen> {
  final _constructionService = ConstructionService();
  
  List<Map<String, dynamic>> _workingSites = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkingSites();
  }

  Future<void> _loadWorkingSites() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _constructionService.getWorkingSites();
      
      if (result['success'] && mounted) {
        setState(() {
          _workingSites = result['sites'] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSite(Map<String, dynamic> site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiteDetailScreen(site: site),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Working Sites'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkingSites,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWorkingSites,
        color: const Color(0xFFFF9800),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
              )
            : _workingSites.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _workingSites.length,
                    itemBuilder: (context, index) {
                      final site = _workingSites[index];
                      return _buildSiteCard(site);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 80,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Working Sites Assigned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your accountant will assign sites to you',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSite(site),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        site['display_name'] ?? site['site_name'] ?? 'Site',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ],
                ),
                
                // Description (if available)
                if (site['description'] != null && site['description'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: const Color(0xFF1A1A2E),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            site['description'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Assigned Date
                if (site['assigned_date'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Assigned: ${site['assigned_date']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
