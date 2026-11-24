class AuditTrailLog {
  final String id;
  final String? actorProfileId;
  final String action;
  final String tableName;
  final String recordId;
  final Map<String, dynamic> details;
  final DateTime createdAt;

  // Auxiliary join fields
  String? actorName;

  AuditTrailLog({
    required this.id,
    this.actorProfileId,
    required this.action,
    required this.tableName,
    required this.recordId,
    this.details = const {},
    DateTime? createdAt,
    this.actorName,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AuditTrailLog.fromJson(Map<String, dynamic> json) {
    return AuditTrailLog(
      id: json['id'] as String,
      actorProfileId: json['actor_profile_id'] as String?,
      action: json['action'] as String,
      tableName: json['table_name'] as String,
      recordId: json['record_id'] as String,
      details: json['details'] != null
          ? Map<String, dynamic>.from(json['details'] as Map)
          : const {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      actorName: json['actor_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actor_profile_id': actorProfileId,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
