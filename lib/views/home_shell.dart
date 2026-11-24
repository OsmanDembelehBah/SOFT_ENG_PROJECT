import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/auth_controller.dart';
import '../controllers/union_controller.dart';
import 'rider_home_dashboard.dart';
import 'rider_ledger_screen.dart';
import 'safety_inspection_screen.dart';
import 'stations_screen.dart';
import 'executive_analytics_screen.dart';
import 'rider_profile_screen.dart';
import 'payment_gateway_screen.dart';
import 'disputes_screen.dart';
import 'announcements_screen.dart';
import 'auth_screen.dart';

/// Screen 15: Primary Navigation Shell & Hub
/// Features dynamic role switching (Rider, Inspector, Admin, Executive),
/// a 5-tab Bottom Navigation Bar, quick notification badges, and a full Union drawer.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RiderHomeDashboard(),
    RiderLedgerScreen(),
    SafetyInspectionScreen(),
    StationsScreen(),
    ExecutiveAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final union = context.watch<UnionController>();

    final unreadNotifs = union.notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.two_wheeler_rounded, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TransitFlow SL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Freetown Motorcycle Union',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Role Badge / Role Switcher Quick Button
          InkWell(
            onTap: () => _showRoleSwitchDialog(context, auth),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _getRoleColor(auth.activeRole).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRoleColor(auth.activeRole).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, size: 14, color: _getRoleColor(auth.activeRole)),
                  const SizedBox(width: 4),
                  Text(
                    auth.currentProfile?.roleDisplay ?? 'Rider',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(auth.activeRole),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Notifications Bell with Unread Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                tooltip: 'Announcements & Alerts',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                  );
                },
              ),
              if (unreadNotifs > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.statusFlagged,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotifs',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),

          // Direct Pay Action
          IconButton(
            icon: const Icon(Icons.payment_rounded, color: AppTheme.primaryGreen),
            tooltip: 'Direct Union Payment',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentGatewayScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(context, auth, union, isDark),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: Icon(Icons.security_outlined),
            selectedIcon: Icon(Icons.security_rounded),
            label: 'Safety',
          ),
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub_rounded),
            label: 'Terminals',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Audit',
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.statusFlagged;
      case 'inspector':
        return AppTheme.accentBlue;
      case 'executive':
        return AppTheme.goldenAmber;
      case 'rider':
      default:
        return AppTheme.primaryGreen;
    }
  }

  Widget _buildDrawer(BuildContext context, AuthController auth, UnionController union, bool isDark) {
    final profile = auth.currentProfile;
    final rider = auth.currentRider;

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer User Header
            Container(
              padding: const EdgeInsets.all(20),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primaryGreen,
                    child: Text(
                      (profile?.fullName.isNotEmpty ?? false) ? profile!.fullName[0] : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.fullName ?? 'Alhaji Bah',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile?.roleDisplay} • ${rider?.riderCode ?? "SL-001"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Rider Dashboard',
                    subtitle: 'Personal compliance & status',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 0);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.badge_rounded,
                    title: 'Rider Licence & Profile',
                    subtitle: 'Driver verification & details',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RiderProfileScreen(rider: rider)),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.payment_rounded,
                    title: 'Pay Union Dues & Levies',
                    subtitle: 'Daily road dues & permit fees',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentGatewayScreen()),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.receipt_long_rounded,
                    title: 'Personal Payment Ledger',
                    subtitle: 'Chronological receipts & logs',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.fact_check_rounded,
                    title: 'Road Safety Inspections',
                    subtitle: '4-point checklist & certificates',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.hub_rounded,
                    title: 'Freetown Station Terminals',
                    subtitle: 'Lumley, Kissy, Wellington...',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.report_problem_rounded,
                    title: 'Disputes & Appeals',
                    subtitle: 'Formal grievance resolution',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DisputesScreen()),
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.analytics_rounded,
                    title: 'Executive Financial Audit',
                    subtitle: 'SDG metrics & immutable audit trail',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 4);
                    },
                  ),
                  _drawerItem(
                    icon: Icons.campaign_rounded,
                    title: 'Union Announcements',
                    subtitle: 'Notices & safety advisories',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Role Switcher & Sign Out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRoleSwitchDialog(context, auth);
                      },
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Switch Role'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      Navigator.pop(context);
                      auth.signOut();
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      onTap: onTap,
      dense: true,
    );
  }

  void _showRoleSwitchDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Simulate Union Persona Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Switch roles instantly to experience the system from different perspectives in Sierra Leone transport operations:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              _roleTile(
                title: 'Alhaji Bah (R001)',
                subtitle: 'Okada Commercial Rider • Lumley Terminal',
                roleKey: 'rider',
                color: AppTheme.primaryGreen,
                currentRole: auth.activeRole,
                onTap: () {
                  auth.switchRole('rider');
                  Navigator.pop(ctx);
                },
              ),
              _roleTile(
                title: 'Alpha Kamara',
                subtitle: 'Safety Inspector • Road Safety Marshal',
                roleKey: 'inspector',
                color: AppTheme.accentBlue,
                currentRole: auth.activeRole,
                onTap: () {
                  auth.switchRole('inspector');
                  Navigator.pop(ctx);
                },
              ),
              _roleTile(
                title: 'Chief Abu Kargbo',
                subtitle: 'Union Executive • Wellington Station Coordinator',
                roleKey: 'executive',
                color: AppTheme.goldenAmber,
                currentRole: auth.activeRole,
                onTap: () {
                  auth.switchRole('executive');
                  Navigator.pop(ctx);
                },
              ),
              _roleTile(
                title: 'Osman Bah',
                subtitle: 'Union President & Central Administrator',
                roleKey: 'admin',
                color: AppTheme.statusFlagged,
                currentRole: auth.activeRole,
                onTap: () {
                  auth.switchRole('admin');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _roleTile({
    required String title,
    required String subtitle,
    required String roleKey,
    required Color color,
    required String currentRole,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRole == roleKey;
    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.person, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
        onTap: onTap,
      ),
    );
  }
}
