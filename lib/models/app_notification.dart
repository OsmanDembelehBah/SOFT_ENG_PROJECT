class AppNotification {
  final String id;
  final String recipientProfileId;
  final String title;
  final String body;
  final String category; // 'PAYMENT', 'INSPECTION', 'PERMIT', 'SAFETY', 'GENERAL'
  bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.recipientProfileId,
    required this.title,
    required this.body,
    this.category = 'PAYMENT',
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      recipientProfileId: json['recipient_profile_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: json['category'] as String? ?? 'PAYMENT',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_profile_id': recipientProfileId,
      'title': title,
      'body': body,
      'category': category,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
