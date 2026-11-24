import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/union_controller.dart';
import '../models/station_zone.dart';
import '../models/station_permit.dart';
import '../widgets/stat_card.dart';
import 'bike_detail_screen.dart';

/// Screen 12: Stations & Zones Operations Screen
/// Operational command center for all 6 Freetown commercial motorcycle zones:
/// Lumley, Kissy, Wellington, Aberdeen, Congo Cross, and Central.
class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormatter = NumberFormat.currency(symbol: 'Le ', decimalDigits: 0);
    final union = context.watch<UnionController>();

    final stations = union.stations;
    final allBikes = union.bikes;
    final allRiders = union.riders;

    final filteredStations = stations.where((s) {
      return _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.zoneCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.coordinatorName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final totalRevenue = allBikes.fold(0.0, (sum, b) => sum + b.totalDuesPaid);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Freetown Station Terminals'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Analytics Stats Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Active Stations',
                      value: stations.length.toString(),
                      subtitle: 'Freetown Urban',
                      icon: Icons.hub_rounded,
                      iconColor: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'Total Fleet',
                      value: allBikes.length.toString(),
                      subtitle: '${allRiders.length} Riders',
                      icon: Icons.two_wheeler_rounded,
                      iconColor: AppTheme.goldenAmber,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: StatCard(
                title: 'Total Station Dues Collected',
                value: currencyFormatter.format(totalRevenue),
                subtitle: 'Zero Cash Leakage • Reconciled Daily',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppTheme.accentBlue,
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Search terminal by name, zone code (LMJ-01), or coordinator...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ),

            // Stations List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredStations.length,
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                final bikesInStation = allBikes.where((b) => b.zoneId == station.id).toList();
                final revenue = bikesInStation.fold(0.0, (sum, b) => sum + b.totalDuesPaid);
                final compliantCount = bikesInStation.where((b) => b.isInspected).length;
                final complianceRate = bikesInStation.isEmpty ? 0.0 : (compliantCount / bikesInStation.length) * 100;

                return _buildStationCard(
                  context: context,
                  station: station,
                  bikesCount: bikesInStation.length,
                  revenue: revenue,
                  complianceRate: complianceRate,
                  bikesInStation: bikesInStation,
                  isDark: isDark,
                  currencyFormatter: currencyFormatter,
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard({
    required BuildContext context,
    required StationZone station,
    required int bikesCount,
    required double revenue,
    required double complianceRate,
    required List<dynamic> bikesInStation,
    required bool isDark,
    required NumberFormat currencyFormatter,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        station.zoneCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryGreen,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      station.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: station.isActive
                        ? AppTheme.primaryGreen.withOpacity(0.12)
                        : Colors.grey.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: station.isActive ? AppTheme.primaryGreen : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        station.isActive ? 'OPERATIONAL' : 'INACTIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: station.isActive ? AppTheme.primaryGreen : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${station.district} • ${station.city}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),

            // Station KPI Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stationStat('Registered Bikes', bikesCount.toString(), Icons.two_wheeler),
                  _statDivider(isDark),
                  _stationStat('Revenue', currencyFormatter.format(revenue), Icons.payments_outlined),
                  _statDivider(isDark),
                  _stationStat(
                    'Compliance',
                    '${complianceRate.toStringAsFixed(0)}%',
                    Icons.security,
                    color: complianceRate >= 80 ? AppTheme.primaryGreen : AppTheme.goldenAmber,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Coordinator Info & Quick Contact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF0F172A),
                        child: Icon(Icons.person, size: 18, color: AppTheme.goldenAmber),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.coordinatorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Terminal Marshal • ${station.phoneContact ?? "+232 76 000000"}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _showCoordinatorContactDialog(context, station),
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('Contact'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),

            // Fleet inspection shortcut
            if (bikesInStation.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showStationFleetSheet(context, station, bikesInStation),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: Text('View All $bikesCount Assigned Bikes in ${station.name} →'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stationStat(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color ?? const Color(0xFF64748B)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _statDivider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
    );
  }

  void _showCoordinatorContactDialog(BuildContext context, StationZone station) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('${station.name} Terminal Marshal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coordinator: ${station.coordinatorName}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text('Official Mobile: ${station.phoneContact ?? "Not specified"}'),
              const SizedBox(height: 4),
              Text('Zone Code: ${station.zoneCode}'),
              Text('Jurisdiction: Western Area Urban, Freetown'),
              const SizedBox(height: 14),
              const Text(
                'Responsible for queue management, local road safety checks, and union levy collection monitoring at this terminal.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Simulating official call to ${station.coordinatorName} (${station.phoneContact}).'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              icon: const Icon(Icons.call, size: 16),
              label: const Text('Call Marshal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStationFleetSheet(BuildContext context, StationZone station, List<dynamic> bikes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${station.name} Fleet',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${bikes.length} commercial motorcycles assigned',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: bikes.length,
                  itemBuilder: (c, i) {
                    final b = bikes[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          b.plateNumber,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      title: Text('${b.make} ${b.model} • ${b.riderName ?? "Unassigned"}'),
                      subtitle: Text('Paid: Le ${b.totalDuesPaid.toStringAsFixed(0)} • Year ${b.manufactureYear}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BikeDetailScreen(bike: b)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
