import '../models/station_zone.dart';
import '../database/local_database.dart';

class StationService {
  final LocalDatabase _db = LocalDatabase();

  List<StationZone> getAllStations() => List.unmodifiable(_db.stationZones);

  StationZone? getStationById(String id) {
    try {
      return _db.stationZones.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }

  int getActiveBikesCount(String zoneId) {
    return _db.bikes.where((b) => b.zoneId == zoneId).length;
  }

  double getStationRevenue(String zoneId) {
    return _db.bikes
        .where((b) => b.zoneId == zoneId)
        .fold(0.0, (sum, b) => sum + b.totalDuesPaid);
  }
}
