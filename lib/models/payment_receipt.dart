class PaymentReceipt {
  final String id;
  final String receiptNumber; // e.g. RCP-20261124-001
  final String dailyLogId;
  final String riderId;
  final String bikeId;
  final double amount;
  final String currency; // 'SLE'
  final DateTime issuedAt;

  // Auxiliary join fields
  String? plateNumber;
  String? riderName;
  String? riderCode;
  String? feeTypeName;
  String? paymentMethod;

  PaymentReceipt({
    required this.id,
    required this.receiptNumber,
    required this.dailyLogId,
    required this.riderId,
    required this.bikeId,
    required this.amount,
    this.currency = 'SLE',
    DateTime? issuedAt,
    this.plateNumber,
    this.riderName,
    this.riderCode,
    this.feeTypeName,
    this.paymentMethod,
  }) : issuedAt = issuedAt ?? DateTime.now();

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    return PaymentReceipt(
      id: json['id'] as String,
      receiptNumber: json['receipt_number'] as String,
      dailyLogId: json['daily_log_id'] as String,
      riderId: json['rider_id'] as String,
      bikeId: json['bike_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'SLE',
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'] as String)
          : null,
      plateNumber: json['plate_number'] as String?,
      riderName: json['rider_name'] as String?,
      riderCode: json['rider_code'] as String?,
      feeTypeName: json['fee_type_name'] as String?,
      paymentMethod: json['payment_method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_number': receiptNumber,
      'daily_log_id': dailyLogId,
      'rider_id': riderId,
      'bike_id': bikeId,
      'amount': amount,
      'currency': currency,
      'issued_at': issuedAt.toIso8601String(),
    };
  }
}
