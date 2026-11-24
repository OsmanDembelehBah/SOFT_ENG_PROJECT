class UnionAnnouncement {
  final String id;
  final String title;
  final String message;
  final String? zoneId;
  final String priority; // 'LOW', 'NORMAL', 'HIGH', 'URGENT'
  final String? publishedByProfileId;
  final DateTime publishedAt;

  // Auxiliary join fields
  String? zoneName;
  String? publisherName;

  UnionAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    this.zoneId,
    this.priority = 'NORMAL',
    this.publishedByProfileId,
    DateTime? publishedAt,
    this.zoneName,
    this.publisherName,
  }) : publishedAt = publishedAt ?? DateTime.now();

  bool get isHighPriority => priority == 'HIGH' || priority == 'URGENT';

  factory UnionAnnouncement.fromJson(Map<String, dynamic> json) {
    return UnionAnnouncement(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      zoneId: json['zone_id'] as String?,
      priority: json['priority'] as String? ?? 'NORMAL',
      publishedByProfileId: json['published_by_profile_id'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      zoneName: json['zone_name'] as String?,
      publisherName: json['publisher_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'zone_id': zoneId,
      'priority': priority,
      'published_by_profile_id': publishedByProfileId,
      'published_at': publishedAt.toIso8601String(),
    };
  }
}
