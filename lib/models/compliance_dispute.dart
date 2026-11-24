class ComplianceDispute {
  final String id;
  final String ticketCode; // e.g. DISP-2026-001
  final String riderId;
  final String bikeId;
  final String? dailyLogId;
  final String subject;
  final String description;
  String status; // 'OPEN', 'IN_REVIEW', 'RESOLVED', 'REJECTED'
  String? resolutionNotes;
  final DateTime createdAt;
  DateTime? resolvedAt;

  // Auxiliary join fields
  String? riderName;
  String? plateNumber;

  ComplianceDispute({
    required this.id,
    required this.ticketCode,
    required this.riderId,
    required this.bikeId,
    this.dailyLogId,
    required this.subject,
    required this.description,
    this.status = 'OPEN',
    this.resolutionNotes,
    DateTime? createdAt,
    this.resolvedAt,
    this.riderName,
    this.plateNumber,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOpen => status == 'OPEN';
  bool get isInReview => status == 'IN_REVIEW';
  bool get isResolved => status == 'RESOLVED';
  bool get isRejected => status == 'REJECTED';

  factory ComplianceDispute.fromJson(Map<String, dynamic> json) {
    return ComplianceDispute(
      id: json['id'] as String,
      ticketCode: json['ticket_code'] as String,
      riderId: json['rider_id'] as String,
      bikeId: json['bike_id'] as String,
      dailyLogId: json['daily_log_id'] as String?,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'OPEN',
      resolutionNotes: json['resolution_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      riderName: json['rider_name'] as String?,
      plateNumber: json['plate_number'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket_code': ticketCode,
      'rider_id': riderId,
      'bike_id': bikeId,
      'daily_log_id': dailyLogId,
      'subject': subject,
      'description': description,
      'status': status,
      'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
    };
  }
}
