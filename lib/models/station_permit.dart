class StationPermit {
  final String id;
  final String permitCode; // e.g. PMT-2026-LMJ-001
  final String bikeId;
  final String riderId;
  final String zoneId;
  final String permitType; // e.g. 'ANNUAL_OPERATIONAL'
  final DateTime issuedDate;
  final DateTime expiryDate;
  final double feeAmount;
  final String status; // 'ACTIVE', 'EXPIRED', 'REVOKED'
  final DateTime createdAt;

  // Auxiliary join fields
  String? plateNumber;
  String? riderName;
  String? zoneName;

  StationPermit({
    required this.id,
    required this.permitCode,
    required this.bikeId,
    required this.riderId,
    required this.zoneId,
    this.permitType = 'ANNUAL_OPERATIONAL',
    DateTime? issuedDate,
    DateTime? expiryDate,
    this.feeAmount = 100000.0,
    this.status = 'ACTIVE',
    DateTime? createdAt,
    this.plateNumber,
    this.riderName,
    this.zoneName,
  })  : issuedDate = issuedDate ?? DateTime.now(),
        expiryDate =
            expiryDate ?? DateTime.now().add(const Duration(days: 365)),
        createdAt = createdAt ?? DateTime.now();

  bool get isActive => status == 'ACTIVE';

  factory StationPermit.fromJson(Map<String, dynamic> json) {
    return StationPermit(
      id: json['id'] as String,
      permitCode: json['permit_code'] as String,
      bikeId: json['bike_id'] as String,
      riderId: json['rider_id'] as String,
      zoneId: json['zone_id'] as String,
      permitType: json['permit_type'] as String? ?? 'ANNUAL_OPERATIONAL',
      issuedDate: json['issued_date'] != null
          ? DateTime.parse(json['issued_date'] as String)
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 100000.0,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      plateNumber: json['plate_number'] as String?,
      riderName: json['rider_name'] as String?,
      zoneName: json['zone_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permit_code': permitCode,
      'bike_id': bikeId,
      'rider_id': riderId,
      'zone_id': zoneId,
      'permit_type': permitType,
      'issued_date': issuedDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'fee_amount': feeAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
