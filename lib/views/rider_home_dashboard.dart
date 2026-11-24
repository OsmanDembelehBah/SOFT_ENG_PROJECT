import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/union_controller.dart';
import '../models/daily_log.dart';
import '../models/union_announcement.dart';
import '../widgets/status_pill.dart';
import '../widgets/bike_rider_visual.dart';
import 'payment_gateway_screen.dart';
import 'payment_receipt_screen.dart';
import 'rider_ledger_screen.dart';
import 'bike_detail_screen.dart';
import 'rider_profile_screen.dart';
import 'disputes_screen.dart';

/// Screen 4: Rider Home Dashboard
/// Personal compliance status card, quick-pay shortcuts, recent ledger preview, and station alerts.
class RiderHomeDashboard extends StatelessWidget {
  const RiderHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final union = context.watch<UnionController>();

    final currentRider = auth.currentRider ?? (union.riders.isNotEmpty ? union.riders.first : null);
    final currentBike = auth.currentBike ??
        (currentRider != null
            ? union.bikes.firstWhere(
                (b) => b.riderId == currentRider.id,
                orElse: () => union.bikes.first,
              )
            : (union.bikes.isNotEmpty ? union.bikes.first : null));

    final bikeLogs = currentBike != null
        ? union.dailyLogs.where((l) => l.bikeId == currentBike.id).toList()
        : <DailyLog>[];

    final announcements = union.announcements;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar with Rider Info
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: Text(
                      currentRider?.riderCode ?? 'R01',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentRider?.fullName ?? 'Commercial Rider',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${currentBike?.plateNumber ?? "BKE-101"} • ${currentRider?.zoneName ?? "Lumley Junction"}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
                tooltip: 'My Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RiderProfileScreen(rider: currentRider),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                tooltip: 'Notifications',
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Personal Compliance Status Card
                  _buildComplianceCard(context, currentRider, currentBike, isDark),

                  const SizedBox(height: 20),

                  // 2. Direct Union Quick-Pay Shortcuts Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Direct Union Payments',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentGatewayScreen(
                                preselectedRiderId: currentRider?.id,
                                preselectedBikeId: currentBike?.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('Open Gateway'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick Pay Grid
                  _buildQuickPayGrid(context, currentRider, currentBike, isDark),

                  const SizedBox(height: 22),

                  // 3. Station Broadcast Alerts / SDG Announcement
                  if (announcements.isNotEmpty) ...[
                    _buildAnnouncementsCard(context, announcements.first, isDark),
                    const SizedBox(height: 22),
                  ],

                  // 4. Recent Immutable Ledger Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Payments & Receipts',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RiderLedgerScreen(
                                rider: currentRider,
                                bike: currentBike,
                              ),
                            ),
                          );
                        },
                        child: const Text('View All Ledger →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (bikeLogs.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'No payment transactions recorded yet for this motorcycle.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bikeLogs.length > 3 ? 3 : bikeLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final log = bikeLogs[idx];
                        return _buildLogTile(context, log, isDark);
                      },
                    ),

                  const SizedBox(height: 24),

                  // 5. Quick Support & Appeal banner
                  _buildSupportBanner(context, isDark, currentRider, currentBike),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(
      BuildContext context, dynamic rider, dynamic bike, bool isDark) {
    final status = bike?.inspectionStatus ?? 'PENDING';
    final totalDues = bike?.totalDuesPaid ?? 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppTheme.primaryGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Motorcycle Compliance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              StatusPill(status: status, isLarge: true),
            ],
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Dues Paid',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTheme.formatLeones(totalDues),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  if (bike != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BikeDetailScreen(bike: bike),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.two_wheeler_rounded, size: 16),
                label: const Text('Fleet Specs'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Station & Licence Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Zone: ${rider?.zoneName ?? "Lumley Junction"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldenAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Licence: ${rider?.licenseNumber ?? "SL-LIC-9981"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.goldenAmber,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPayGrid(
      BuildContext context, dynamic rider, dynamic bike, bool isDark) {
    final shortcuts = [
      {
        'title': 'Daily Levy',
        'amount': 25000.0,
        'amountStr': 'Le 25,000',
        'code': 'DAILY_LEVY',
        'icon': Icons.today_rounded,
        'color': AppTheme.primaryGreen,
      },
      {
        'title': 'Safety Fine',
        'amount': 15000.0,
        'amountStr': 'Le 15,000',
        'code': 'SAFETY_FINE',
        'icon': Icons.gavel_rounded,
        'color': AppTheme.statusPending,
      },
      {
        'title': 'Annual Permit',
        'amount': 100000.0,
        'amountStr': 'Le 100,000',
        'code': 'ANNUAL_PERMIT',
        'icon': Icons.card_membership_rounded,
        'color': AppTheme.accentBlue,
      },
      {
        'title': 'Custom Amount',
        'amount': 0.0,
        'amountStr': 'Custom Le',
        'code': 'CUSTOM_PAYMENT',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFF9C27B0),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, idx) {
        final item = shortcuts[idx];
        return Card(
          elevation: 1,
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentGatewayScreen(
                    preselectedRiderId: rider?.id,
                    preselectedBikeId: bike?.id,
                    preselectedFeeCode: item['code'] as String,
                    preselectedAmount: (item['amount'] as double) > 0
                        ? item['amount'] as double
                        : null,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          size: 18,
                          color: item['color'] as Color,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['amountStr'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnnouncementsCard(
      BuildContext context, UnionAnnouncement announcement, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  announcement.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  announcement.priority,
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.message,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, DailyLog log, bool isDark) {
    return Card(
      elevation: 0.5,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_rounded, color: AppTheme.primaryGreen, size: 20),
        ),
        title: Text(
          log.feeTypeName ?? 'Union Levy',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          '${log.logCode} • ${AppTheme.formatDate(log.paidAt)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppTheme.formatLeones(log.amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Digital Receipt →',
              style: TextStyle(fontSize: 10, color: AppTheme.accentBlue),
            ),
          ],
        ),
        onTap: () {
          final union = context.read<UnionController>();
          final receipt = union.receipts.firstWhere(
            (r) => r.dailyLogId == log.id,
            orElse: () => union.receipts.first,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentReceiptScreen(receipt: receipt, dailyLog: log),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupportBanner(
      BuildContext context, bool isDark, dynamic rider, dynamic bike) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.goldenAmber.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline_rounded, color: AppTheme.goldenAmber),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have an Inspection or Fine Dispute?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Submit an official appeal to the union executive committee.',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DisputesScreen(
                    defaultRiderId: rider?.id,
                    defaultBikeId: bike?.id,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldenAmber,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('Appeal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
