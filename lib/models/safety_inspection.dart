class SafetyInspection {
  final String id;
  final String inspectionCode; // e.g. INSP-202611-001
  final String bikeId;
  final String riderId;
  final String? inspectorProfileId;
  final bool brakesOk;
  final bool lightsOk;
  final bool tiresOk;
  final bool helmetGearOk;
  final String status; // 'PASSED', 'PENDING', 'FLAGGED'
  final String? remarks;
  final DateTime inspectedAt;
  final DateTime expiresAt;

  // Auxiliary join fields
  String? plateNumber;
  String? bikeModel;
  String? riderName;
  String? inspectorName;

  SafetyInspection({
    required this.id,
    required this.inspectionCode,
    required this.bikeId,
    required this.riderId,
    this.inspectorProfileId,
    this.brakesOk = true,
    this.lightsOk = true,
    this.tiresOk = true,
    this.helmetGearOk = true,
    this.status = 'PENDING',
    this.remarks,
    DateTime? inspectedAt,
    DateTime? expiresAt,
    this.plateNumber,
    this.bikeModel,
    this.riderName,
    this.inspectorName,
  })  : inspectedAt = inspectedAt ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(const Duration(days: 90));

  bool get isPassed => status == 'PASSED';
  bool get isPending => status == 'PENDING';
  bool get isFlagged => status == 'FLAGGED';

  factory SafetyInspection.fromJson(Map<String, dynamic> json) {
    return SafetyInspection(
      id: json['id'] as String,
      inspectionCode: json['inspection_code'] as String,
      bikeId: json['bike_id'] as String,
      riderId: json['rider_id'] as String,
      inspectorProfileId: json['inspector_profile_id'] as String?,
      brakesOk: json['brakes_ok'] as bool? ?? true,
      lightsOk: json['lights_ok'] as bool? ?? true,
      tiresOk: json['tires_ok'] as bool? ?? true,
      helmetGearOk: json['helmet_gear_ok'] as bool? ?? true,
      status: json['status'] as String? ?? 'PENDING',
      remarks: json['remarks'] as String?,
      inspectedAt: json['inspected_at'] != null
          ? DateTime.parse(json['inspected_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      plateNumber: json['plate_number'] as String?,
      bikeModel: json['model'] as String?,
      riderName: json['rider_name'] as String?,
      inspectorName: json['inspector_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspection_code': inspectionCode,
      'bike_id': bikeId,
      'rider_id': riderId,
      'inspector_profile_id': inspectorProfileId,
      'brakes_ok': brakesOk,
      'lights_ok': lightsOk,
      'tires_ok': tiresOk,
      'helmet_gear_ok': helmetGearOk,
      'status': status,
      'remarks': remarks,
      'inspected_at': inspectedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
