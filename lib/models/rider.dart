class Rider {
  final String id;
  final String riderCode; // e.g. R001, R002, R003
  final String? profileId;
  final String fullName;
  final String phoneNumber;
  final String licenseNumber;
  final String zoneId;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String status; // 'ACTIVE', 'SUSPENDED', 'INACTIVE'
  final DateTime registeredAt;

  // Auxiliary join fields for UI display
  String? zoneName;
  String? linkedPlateNumber;
  String? linkedBikeModel;
  bool? isInspected;
  double? totalDuesPaid;
  String? inspectionStatus;

  Rider({
    required this.id,
    required this.riderCode,
    this.profileId,
    required this.fullName,
    required this.phoneNumber,
    required this.licenseNumber,
    required this.zoneId,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.status = 'ACTIVE',
    DateTime? registeredAt,
    this.zoneName,
    this.linkedPlateNumber,
    this.linkedBikeModel,
    this.isInspected,
    this.totalDuesPaid,
    this.inspectionStatus,
  }) : registeredAt = registeredAt ?? DateTime.now();

  bool get isActive => status == 'ACTIVE';

  factory Rider.fromJson(Map<String, dynamic> json) {
    return Rider(
      id: json['id'] as String,
      riderCode: json['rider_code'] as String,
      profileId: json['profile_id'] as String?,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      licenseNumber: json['license_number'] as String,
      zoneId: json['zone_id'] as String,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      registeredAt: json['registered_at'] != null
          ? DateTime.parse(json['registered_at'] as String)
          : null,
      zoneName: json['zone_name'] as String?,
      linkedPlateNumber: json['plate_number'] as String?,
      linkedBikeModel: json['model'] as String?,
      isInspected: json['is_inspected'] as bool?,
      totalDuesPaid: (json['total_dues_paid'] != null)
          ? (json['total_dues_paid'] as num).toDouble()
          : null,
      inspectionStatus: json['inspection_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_code': riderCode,
      'profile_id': profileId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'license_number': licenseNumber,
      'zone_id': zoneId,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'status': status,
      'registered_at': registeredAt.toIso8601String(),
    };
  }
}
