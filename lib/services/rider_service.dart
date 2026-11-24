import '../models/rider.dart';
import '../models/bike.dart';
import '../database/local_database.dart';

class RiderService {
  final LocalDatabase _db = LocalDatabase();

  List<Rider> getAllRiders() => List.unmodifiable(_db.riders);

  List<Bike> getAllBikes() => List.unmodifiable(_db.bikes);

  Rider? getRiderById(String id) {
    try {
      return _db.riders.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Rider? getRiderByCode(String code) {
    try {
      return _db.riders.firstWhere(
          (r) => r.riderCode.toUpperCase() == code.trim().toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Bike? getBikeForRider(String riderId) {
    try {
      return _db.bikes.firstWhere((b) => b.riderId == riderId);
    } catch (_) {
      return null;
    }
  }

  Bike? getBikeByPlate(String plate) {
    try {
      return _db.bikes.firstWhere(
          (b) => b.plateNumber.toUpperCase() == plate.trim().toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> registerRiderWithBike({
    required String riderCode,
    required String fullName,
    required String phoneNumber,
    required String licenseNumber,
    required String zoneId,
    required String password,
    required String plateNumber,
    required String model,
    String make = 'Bajaj',
    String color = 'Red',
    int manufactureYear = 2024,
    String? chassisNumber,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return _db.registerRiderWithBike(
      riderCode: riderCode,
      fullName: fullName,
      phoneNumber: phoneNumber,
      licenseNumber: licenseNumber,
      zoneId: zoneId,
      password: password,
      plateNumber: plateNumber,
      model: model,
      make: make,
      color: color,
      manufactureYear: manufactureYear,
      chassisNumber: chassisNumber,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );
  }
}
