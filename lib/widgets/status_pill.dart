import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusPill({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'PASSED':
      case 'ACTIVE':
      case 'RESOLVED':
        bg = AppTheme.statusPassed.withOpacity(0.15);
        fg = AppTheme.statusPassed;
        icon = Icons.check_circle_rounded;
        break;
      case 'PENDING':
      case 'IN_REVIEW':
        bg = AppTheme.statusPending.withOpacity(0.15);
        fg = AppTheme.statusPending;
        icon = Icons.hourglass_top_rounded;
        break;
      case 'FLAGGED':
      case 'SUSPENDED':
      case 'REJECTED':
      case 'OVERDUE':
        bg = AppTheme.statusFlagged.withOpacity(0.15);
        fg = AppTheme.statusFlagged;
        icon = Icons.warning_rounded;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        fg = Colors.grey.shade700;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isLarge ? 16 : 12, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontSize: isLarge ? 12 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
