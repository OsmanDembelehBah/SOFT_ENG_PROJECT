class Bike {
  final String id;
  final String plateNumber; // e.g. BKE-101
  final String riderId;
  final String? zoneId;
  final String make;
  final String model;
  final String color;
  final int manufactureYear;
  final String? chassisNumber;
  String inspectionStatus; // 'PENDING', 'PASSED', 'FLAGGED'
  bool isInspected;
  double totalDuesPaid;
  final DateTime createdAt;
  DateTime updatedAt;

  // Auxiliary join fields
  String? riderName;
  String? riderPhone;
  String? riderCode;
  String? zoneName;

  Bike({
    required this.id,
    required this.plateNumber,
    required this.riderId,
    this.zoneId,
    this.make = 'Bajaj',
    required this.model,
    this.color = 'Red',
    this.manufactureYear = 2023,
    this.chassisNumber,
    this.inspectionStatus = 'PENDING',
    this.isInspected = false,
    this.totalDuesPaid = 0.0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.riderName,
    this.riderPhone,
    this.riderCode,
    this.zoneName,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isPassed => inspectionStatus == 'PASSED';
  bool get isPending => inspectionStatus == 'PENDING';
  bool get isFlagged => inspectionStatus == 'FLAGGED';

  factory Bike.fromJson(Map<String, dynamic> json) {
    return Bike(
      id: json['id'] as String,
      plateNumber: json['plate_number'] as String,
      riderId: json['rider_id'] as String,
      zoneId: json['zone_id'] as String?,
      make: json['make'] as String? ?? 'Bajaj',
      model: json['model'] as String,
      color: json['color'] as String? ?? 'Red',
      manufactureYear: json['manufacture_year'] as int? ?? 2023,
      chassisNumber: json['chassis_number'] as String?,
      inspectionStatus: json['inspection_status'] as String? ?? 'PENDING',
      isInspected: json['is_inspected'] as bool? ?? false,
      totalDuesPaid: (json['total_dues_paid'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      riderName: json['rider_name'] as String?,
      riderPhone: json['rider_phone'] as String?,
      riderCode: json['rider_code'] as String?,
      zoneName: json['zone_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plate_number': plateNumber,
      'rider_id': riderId,
      'zone_id': zoneId,
      'make': make,
      'model': model,
      'color': color,
      'manufacture_year': manufactureYear,
      'chassis_number': chassisNumber,
      'inspection_status': inspectionStatus,
      'is_inspected': isInspected,
      'total_dues_paid': totalDuesPaid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
