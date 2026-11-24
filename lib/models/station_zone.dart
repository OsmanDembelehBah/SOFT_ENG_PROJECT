class StationZone {
  final String id;
  final String zoneCode;
  final String name;
  final String district;
  final String city;
  final String coordinatorName;
  final String? phoneContact;
  final bool isActive;
  final DateTime createdAt;

  StationZone({
    required this.id,
    required this.zoneCode,
    required this.name,
    this.district = 'Western Area Urban',
    this.city = 'Freetown',
    required this.coordinatorName,
    this.phoneContact,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory StationZone.fromJson(Map<String, dynamic> json) {
    return StationZone(
      id: json['id'] as String,
      zoneCode: json['zone_code'] as String,
      name: json['name'] as String,
      district: json['district'] as String? ?? 'Western Area Urban',
      city: json['city'] as String? ?? 'Freetown',
      coordinatorName: json['coordinator_name'] as String? ?? 'Station Marshal',
      phoneContact: json['phone_contact'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone_code': zoneCode,
      'name': name,
      'district': district,
      'city': city,
      'coordinator_name': coordinatorName,
      'phone_contact': phoneContact,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
