import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/change_request_provider.dart';
import '../utils/app_colors.dart';

class SupervisorChangesScreen extends StatefulWidget {
  const SupervisorChangesScreen({super.key});

  @override
  State<SupervisorChangesScreen> createState() => _SupervisorChangesScreenState();
}

class _SupervisorChangesScreenState extends State<SupervisorChangesScreen> {
  @override
  void initState() {
    super.initState();
    // Load modified entries only once using provider caching
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangeRequestProvider>().loadModifiedEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeRequestProvider>(
      builder: (context, provider, child) {
        final labourEntries = provider.modifiedLabourEntries;
        final materialEntries = provider.modifiedMaterialEntries;
        final isLoading = provider.isLoadingModified;

        final allEntries = [
          ...labourEntries.map((e) => {'type': 'labour', 'data': e}),
          ...materialEntries.map((e) => {'type': 'material', 'data': e}),
        ];

        // Sort by modified date
        allEntries.sort((a, b) {
          final dataA = a['data'] as Map<String, dynamic>?;
          final dataB = b['data'] as Map<String, dynamic>?;
          final dateA = dataA?['modified_at'] as String?;
          final dateB = dataB?['modified_at'] as String?;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            title: const Text(
              'Modified Entries',
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
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: const Color(0xFF1A1A2E)),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadModifiedEntries(forceRefresh: true),
                  color: const Color(0xFF1A1A2E),
                  child: allEntries.isEmpty
                      ? _buildEmptyState()
                      : _buildEntriesList(allEntries),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_off,
            size: 80,
            color: const Color(0xFF6B7280).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Modified Entries',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Entries modified by accountant will appear here',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<Map<String, dynamic>> entries) {
    // Group by date
    final groupedEntries = <String, List<Map<String, dynamic>>>{};
    for (var entry in entries) {
      final date = _formatDateHeader(entry['data']['modified_at']);
      groupedEntries.putIfAbsent(date, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) {
        final date = groupedEntries.keys.elementAt(index);
        final dateEntries = groupedEntries[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            ...dateEntries.map((entry) {
              if (entry['type'] == 'labour') {
                return _buildLabourCard(entry['data']);
              } else {
                return _buildMaterialCard(entry['data']);
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildLabourCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF44336).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 14, color: const Color(0xFFF44336)),
                  SizedBox(width: 4),
                  Text(
                    'MODIFIED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF44336),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Modified by
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, size: 18, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modified by',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        entry['modified_by_name'] ?? 'Accountant',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Site info
            Text(
              entry['site_name'] ?? 'Unknown Site',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            // Labour details
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.engineering,
                    entry['labour_type'] ?? 'General',
                    const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.groups,
                    '${entry['labour_count'] ?? 0} Workers',
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            if (entry['modification_reason'] != null && entry['modification_reason'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: const Color(0xFF1A1A2E)),
                        SizedBox(width: 6),
                        Text(
                          'Reason for Change',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry['modification_reason'],
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF44336).withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modified badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 14, color: const Color(0xFFF44336)),
                  SizedBox(width: 4),
                  Text(
                    'MODIFIED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF44336),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Modified by
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person, size: 18, color: const Color(0xFF1A1A2E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modified by',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        entry['modified_by_name'] ?? 'Accountant',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Site info
            Text(
              entry['site_name'] ?? 'Unknown Site',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            // Material details
            Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    Icons.category,
                    entry['material_type'] ?? 'Unknown',
                    const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(
                    Icons.straighten,
                    '${entry['quantity'] ?? 0} ${entry['unit'] ?? ''}',
                    const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            if (entry['modification_reason'] != null && entry['modification_reason'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: const Color(0xFF1A1A2E)),
                        SizedBox(width: 6),
                        Text(
                          'Reason for Change',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry['modification_reason'],
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(String? dateStr) {
    if (dateStr == null) return 'Unknown Date';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final entryDate = DateTime(date.year, date.month, date.day);

      if (entryDate == today) {
        return 'Today';
      } else if (entryDate == yesterday) {
        return 'Yesterday';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
