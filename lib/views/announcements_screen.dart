import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../controllers/union_controller.dart';
import '../models/union_announcement.dart';
import '../models/app_notification.dart';

/// Screen 14: Union Announcements & Notifications Screen
/// Displays official executive notices, emergency traffic advisories across Freetown,
/// safety campaigns, and personal rider notifications.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPriorityFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final union = context.watch<UnionController>();

    final announcements = union.announcements;
    final filteredAnnouncements = announcements.where((a) {
      if (_selectedPriorityFilter == 'ALL') return true;
      return a.priority.toUpperCase() == _selectedPriorityFilter;
    }).toList();

    final notifications = union.notifications;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Announcements & Alerts'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryGreen,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          tabs: [
            Tab(icon: const Icon(Icons.campaign_outlined), text: 'Union Notices (${announcements.length})'),
            Tab(icon: const Icon(Icons.notifications_none_rounded), text: 'Alerts (${notifications.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Union Announcements
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _priorityFilterChip('ALL', 'All Notices'),
                      const SizedBox(width: 8),
                      _priorityFilterChip('URGENT', 'Urgent Advisories'),
                      const SizedBox(width: 8),
                      _priorityFilterChip('HIGH', 'High Priority'),
                      const SizedBox(width: 8),
                      _priorityFilterChip('NORMAL', 'Standard Notices'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filteredAnnouncements.isEmpty
                    ? Center(
                        child: Text(
                          'No announcements in this category.',
                          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAnnouncements.length,
                        itemBuilder: (context, index) {
                          final a = filteredAnnouncements[index];
                          return _announcementCard(a, isDark);
                        },
                      ),
              ),
            ],
          ),

          // TAB 2: Personal Notifications
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${notifications.where((n) => !n.isRead).length} Unread Alerts',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () => union.markAllNotificationsRead(),
                      child: const Text('Mark All as Read', style: TextStyle(color: AppTheme.primaryGreen)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications yet.',
                          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return _notificationCard(context, notif, union, isDark);
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priorityFilterChip(String key, String label) {
    final isSelected = _selectedPriorityFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedPriorityFilter = key);
      },
      selectedColor: AppTheme.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _announcementCard(UnionAnnouncement a, bool isDark) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm');
    Color badgeColor;
    switch (a.priority.toUpperCase()) {
      case 'URGENT':
        badgeColor = AppTheme.statusFlagged;
        break;
      case 'HIGH':
        badgeColor = AppTheme.goldenAmber;
        break;
      default:
        badgeColor = AppTheme.primaryGreen;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: a.isHighPriority ? badgeColor.withOpacity(0.5) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: a.isHighPriority ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${a.priority.toUpperCase()} PRIORITY',
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(a.publishedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              a.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              a.message,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issued by: ${a.publisherName ?? "Union General Secretary"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  a.zoneName ?? 'All Freetown Stations',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, AppNotification notif, UnionController union, bool isDark) {
    final dateFormat = DateFormat('dd MMM • HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: notif.isRead ? 0 : 1,
      color: notif.isRead
          ? (isDark ? const Color(0xFF1E293B).withOpacity(0.6) : const Color(0xFFF8FAFC))
          : (isDark ? const Color(0xFF1E293B) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: notif.isRead
              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
              : AppTheme.primaryGreen.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: notif.isRead
              ? Colors.grey.withOpacity(0.15)
              : AppTheme.primaryGreen.withOpacity(0.15),
          child: Icon(
            notif.category == 'PAYMENT'
                ? Icons.receipt_long
                : (notif.category == 'INSPECTION' ? Icons.security : Icons.notifications),
            color: notif.isRead ? Colors.grey : AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notif.body,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(notif.createdAt),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: notif.isRead
            ? null
            : IconButton(
                icon: const Icon(Icons.check, size: 18, color: AppTheme.primaryGreen),
                tooltip: 'Mark read',
                onPressed: () => union.markNotificationRead(notif.id),
              ),
      ),
    );
  }
}
