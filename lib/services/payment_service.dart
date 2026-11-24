import '../models/fee_type.dart';
import '../models/daily_log.dart';
import '../models/payment_receipt.dart';
import '../database/local_database.dart';
import 'supabase_service.dart';

class PaymentService {
  final LocalDatabase _db = LocalDatabase();
  final SupabaseService _supabaseService = SupabaseService();

  List<FeeType> getFeeTypes() => List.unmodifiable(_db.feeTypes);

  List<DailyLog> getAllDailyLogs() => List.unmodifiable(_db.dailyLogs);

  List<PaymentReceipt> getAllReceipts() => List.unmodifiable(_db.paymentReceipts);

  List<DailyLog> getLogsForBike(String bikeId) {
    return _db.dailyLogs.where((l) => l.bikeId == bikeId).toList();
  }

  List<DailyLog> getLogsForRider(String riderId) {
    return _db.dailyLogs.where((l) => l.riderId == riderId).toList();
  }

  PaymentReceipt? getReceiptById(String receiptId) {
    try {
      return _db.paymentReceipts.firstWhere((r) => r.id == receiptId);
    } catch (_) {
      return null;
    }
  }

  PaymentReceipt? getReceiptByLogId(String logId) {
    try {
      return _db.paymentReceipts.firstWhere((r) => r.dailyLogId == logId);
    } catch (_) {
      return null;
    }
  }

  /// Process direct payment using transactional RPC function
  Future<Map<String, dynamic>> processPayment({
    required String bikeId,
    required String riderId,
    required String feeTypeId,
    required double amount,
    String paymentMethod = 'CASH_OFFICIAL',
    String? notes,
    String? recorderProfileId,
  }) async {
    return await _supabaseService.executePaymentRpc(
      bikeId: bikeId,
      riderId: riderId,
      feeTypeId: feeTypeId,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
      recorderProfileId: recorderProfileId,
    );
  }
}
