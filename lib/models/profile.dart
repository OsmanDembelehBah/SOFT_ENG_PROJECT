class Profile {
  final String id;
  final String username;
  final String fullName;
  final String? phoneNumber;
  final String role; // 'rider', 'admin', 'inspector', 'executive'
  final String? avatarUrl;
  final String authProvider;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.username,
    required this.fullName,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
    this.authProvider = 'email',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isAdmin => role == 'admin';
  bool get isInspector => role == 'inspector';
  bool get isExecutive => role == 'executive';
  bool get isRider => role == 'rider';

  String get roleDisplay {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'inspector':
        return 'Safety Inspector';
      case 'executive':
        return 'Union Executive';
      case 'rider':
      default:
        return 'Okada Rider';
    }
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String? ?? 'rider',
      avatarUrl: json['avatar_url'] as String?,
      authProvider: json['auth_provider'] as String? ?? 'email',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'avatar_url': avatarUrl,
      'auth_provider': authProvider,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
