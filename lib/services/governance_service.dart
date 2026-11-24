import '../models/compliance_dispute.dart';
import '../models/union_announcement.dart';
import '../models/app_notification.dart';
import '../models/audit_trail_log.dart';
import '../database/local_database.dart';

class GovernanceService {
  final LocalDatabase _db = LocalDatabase();

  List<ComplianceDispute> getAllDisputes() =>
      List.unmodifiable(_db.complianceDisputes);

  List<UnionAnnouncement> getAllAnnouncements() =>
      List.unmodifiable(_db.unionAnnouncements);

  List<AppNotification> getNotificationsForProfile(String profileId) {
    return _db.notifications
        .where((n) => n.recipientProfileId == profileId)
        .toList();
  }

  List<AppNotification> getAllNotifications() =>
      List.unmodifiable(_db.notifications);

  List<AuditTrailLog> getAllAuditLogs() =>
      List.unmodifiable(_db.auditTrailLogs);

  ComplianceDispute submitDispute({
    required String riderId,
    required String bikeId,
    String? dailyLogId,
    required String subject,
    required String description,
  }) {
    return _db.submitDispute(
      riderId: riderId,
      bikeId: bikeId,
      dailyLogId: dailyLogId,
      subject: subject,
      description: description,
    );
  }

  void updateDisputeStatus({
    required String disputeId,
    required String status,
    required String resolutionNotes,
  }) {
    _db.updateDisputeStatus(
      disputeId: disputeId,
      status: status,
      resolutionNotes: resolutionNotes,
    );
  }

  void markNotificationRead(String id) {
    _db.markNotificationAsRead(id);
  }

  void markAllNotificationsRead() {
    _db.markAllNotificationsAsRead();
  }
}
