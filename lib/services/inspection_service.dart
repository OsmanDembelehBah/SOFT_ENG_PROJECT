import '../models/safety_inspection.dart';
import '../database/local_database.dart';

class InspectionService {
  final LocalDatabase _db = LocalDatabase();

  List<SafetyInspection> getAllInspections() =>
      List.unmodifiable(_db.safetyInspections);

  List<SafetyInspection> getInspectionsForBike(String bikeId) {
    return _db.safetyInspections.where((i) => i.bikeId == bikeId).toList();
  }

  Map<String, dynamic> recordInspection({
    required String bikeId,
    required bool brakesOk,
    required bool lightsOk,
    required bool tiresOk,
    required bool helmetGearOk,
    required String status,
    String? remarks,
    String? inspectorProfileId,
    String? inspectorName,
  }) {
    return _db.recordSafetyInspection(
      bikeId: bikeId,
      brakesOk: brakesOk,
      lightsOk: lightsOk,
      tiresOk: tiresOk,
      helmetGearOk: helmetGearOk,
      status: status,
      remarks: remarks,
      inspectorProfileId: inspectorProfileId,
      inspectorName: inspectorName,
    );
  }
}
