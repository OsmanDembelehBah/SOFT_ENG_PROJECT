import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/bike.dart';
import '../controllers/auth_controller.dart';
import '../controllers/union_controller.dart';
import '../widgets/status_pill.dart';
import 'payment_gateway_screen.dart';
import 'disputes_screen.dart';
import 'safety_inspection_screen.dart';

/// Screen 9: Motorcycle Fleet & Bike Detail Screen
/// Features comprehensive motorcycle specifications, QR verification matrix,
/// 4-point safety checklist status, dues payment tally, and quick operational actions.
class BikeDetailScreen extends StatelessWidget {
  final Bike bike;

  const BikeDetailScreen({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: 'Le ', decimalDigits: 2);
    final union = context.watch<UnionController>();
    final auth = context.watch<AuthController>();

    // Fetch the latest state of the bike from controller if available
    final currentBike = union.bikes.firstWhere(
      (b) => b.id == bike.id,
      orElse: () => bike,
    );

    final inspections = union.inspections.where((i) => i.bikeId == currentBike.id).toList();
    final latestInspection = inspections.isNotEmpty ? inspections.first : null;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(currentBike.plateNumber),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'File Dispute for this Motorcycle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DisputesScreen(
                    defaultRiderId: currentBike.riderId,
                    defaultBikeId: currentBike.id,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Plate & Verification Header Card
            Container(
              padding: const EdgeInsets.all(20),
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
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.goldenAmber, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_bike, color: AppTheme.goldenAmber, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              currentBike.plateNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(status: currentBike.inspectionStatus, isLarge: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${currentBike.make} ${currentBike.model}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manufactured ${currentBike.manufactureYear} • ${currentBike.color} • ${currentBike.zoneName ?? "Freetown Central"}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // QR Digital Verification Token
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.blueGrey.shade800),
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SL-ROADWORTHY DIGITAL TOKEN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentBike.isPassed ? 'Verified Operational' : 'Action Required',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scan with TransitFlow Marshal scanner at Lumley, Kissy, or Wellington stations.',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Financial Summary Card
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CUMULATIVE UNION DUES PAID',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Icon(Icons.verified, color: AppTheme.primaryGreen, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(currentBike.totalDuesPaid),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentGatewayScreen(
                                    preselectedBikeId: currentBike.id,
                                    preselectedRiderId: currentBike.riderId,
                                    preselectedFeeCode: 'DAILY_LEVY',
                                    preselectedAmount: 25000.0,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment_rounded, size: 18),
                            label: const Text('Pay Daily Levy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Fleet Technical Specifications Table
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Technical & Registry Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _specRow('Chassis Number', currentBike.chassisNumber ?? 'CH-${currentBike.plateNumber}', isDark),
                    _divider(isDark),
                    _specRow('Make & Manufacturer', currentBike.make, isDark),
                    _divider(isDark),
                    _specRow('Model Designation', currentBike.model, isDark),
                    _divider(isDark),
                    _specRow('Chassis Body Color', currentBike.color, isDark),
                    _divider(isDark),
                    _specRow('Model Year', currentBike.manufactureYear.toString(), isDark),
                    _divider(isDark),
                    _specRow('Assigned Zone Terminal', currentBike.zoneName ?? 'Central Zone', isDark),
                    _divider(isDark),
                    _specRow('Registered Rider', currentBike.riderName ?? 'Station Member', isDark),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 4-Point Safety Inspection Status Card
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '4-Point Road Safety Checklist',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (auth.isAdmin || auth.isInspector)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SafetyInspectionScreen(preselectedBikeId: currentBike.id),
                                ),
                              );
                            },
                            icon: const Icon(Icons.fact_check_outlined, size: 16),
                            label: const Text('Inspect Now'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.accentBlue,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _checklistRow(
                      icon: Icons.speed_rounded,
                      title: 'Dual Braking System',
                      subtitle: 'Front disc & rear drum hydraulic response',
                      isOk: latestInspection?.brakesOk ?? currentBike.isPassed,
                    ),
                    _divider(isDark),
                    _checklistRow(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'Headlight & Turn Signals',
                      subtitle: 'High/low beam, rear brake light, side indicators',
                      isOk: latestInspection?.lightsOk ?? currentBike.isPassed,
                    ),
                    _divider(isDark),
                    _checklistRow(
                      icon: Icons.tire_repair_rounded,
                      title: 'Tyre Tread Depth & Pressure',
                      subtitle: 'Minimum 2.0mm tread wear requirement',
                      isOk: latestInspection?.tiresOk ?? currentBike.isPassed,
                    ),
                    _divider(isDark),
                    _checklistRow(
                      icon: Icons.sports_motorsports_rounded,
                      title: 'Dual Certified Helmets',
                      subtitle: 'Standard safety gear for rider and passenger',
                      isOk: latestInspection?.helmetGearOk ?? currentBike.isPassed,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Inspection History Log
            if (inspections.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Inspection History',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...inspections.take(3).map((insp) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: insp.isPassed
                                      ? AppTheme.primaryGreen.withOpacity(0.12)
                                      : AppTheme.statusFlagged.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  insp.isPassed ? Icons.verified : Icons.warning_amber_rounded,
                                  color: insp.isPassed ? AppTheme.primaryGreen : AppTheme.statusFlagged,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      insp.inspectionCode,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Inspector: ${insp.inspectorName ?? "Safety Marshal"} • ${DateFormat("dd MMM yyyy").format(insp.inspectedAt)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StatusPill(status: insp.status),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Action Shortcuts (Pay Dues / File Dispute / Conduct Inspection)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DisputesScreen(
                            defaultRiderId: currentBike.riderId,
                            defaultBikeId: currentBike.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.report_problem_outlined, size: 16),
                    label: const Text('File Dispute'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SafetyInspectionScreen(preselectedBikeId: currentBike.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in, size: 16),
                    label: const Text('Safety Check'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldenAmber,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _checklistRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOk,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isOk ? AppTheme.primaryGreen : AppTheme.statusFlagged),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Icon(
          isOk ? Icons.check_circle : Icons.cancel,
          color: isOk ? AppTheme.primaryGreen : AppTheme.statusFlagged,
          size: 18,
        ),
      ],
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
    );
  }
}
