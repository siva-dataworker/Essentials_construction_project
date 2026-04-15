import 'package:flutter/material.dart';

/// Shared Design System for Essential Homes Construction App
class AppDesign {
  // ── Core Palette ──────────────────────────────────────────────────────────
  static const Color dark1 = Color(0xFF1A1A2E);
  static const Color dark2 = Color(0xFF16213E);
  static const Color dark3 = Color(0xFF0F3460);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);

  // ── Accent Colours ────────────────────────────────────────────────────────
  static const Color green = Color(0xFF4CAF50);
  static const Color blue = Color(0xFF2196F3);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFF44336);
  static const Color amber = Color(0xFFFFC107);
  static const Color teal = Color(0xFF009688);
  static const Color purple = Color(0xFF9C27B0);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color cyan = Color(0xFF00BCD4);

  // ── Gradient ──────────────────────────────────────────────────────────────
  static const LinearGradient headerGradient = LinearGradient(
    colors: [dark1, dark2, dark3],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get smallShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  // ── Status colour ─────────────────────────────────────────────────────────
  static Color colorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
      case 'completed':
      case 'resolved':
        return green;
      case 'pending':
      case 'in progress':
      case 'in_progress':
        return orange;
      case 'on hold':
      case 'rejected':
      case 'overdue':
        return red;
      default:
        return Colors.grey;
    }
  }

  // ── Currency formatter ────────────────────────────────────────────────────
  static String formatCurrency(dynamic amount) {
    double value = amount is String
        ? double.tryParse(amount) ?? 0
        : (amount as num?)?.toDouble() ?? 0;
    if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(2)} Cr';
    if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(2)} L';
    if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)} K';
    return '₹${value.toStringAsFixed(0)}';
  }

  // ── Date formatter ────────────────────────────────────────────────────────
  static String formatDate(String? dateStr, {bool showRelative = true}) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      if (showRelative) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));
        final check = DateTime(dt.year, dt.month, dt.day);
        if (check == today) return 'Today';
        if (check == yesterday) return 'Yesterday';
      }
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return dateStr.length > 10 ? dateStr.substring(0, 10) : dateStr;
    }
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  static Widget sectionHeader(String title,
      {IconData? icon, int? count, Color? countColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: dark1.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: dark1, size: 16),
          ),
          const SizedBox(width: 8),
        ],
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: countColor ?? dark1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ],
    );
  }

  static Widget statusChip(String label, Color color, {double fontSize = 11}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
    );
  }

  static Widget emptyState(String message, IconData icon,
      {String? actionLabel, VoidCallback? onAction}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: dark1.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: Colors.grey.shade300),
            ),
            const SizedBox(height: 20),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade400)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: dark1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget logoutButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}
