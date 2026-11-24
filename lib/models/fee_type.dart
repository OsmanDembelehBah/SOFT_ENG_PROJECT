class FeeType {
  final String id;
  final String code; // 'DAILY_LEVY', 'SAFETY_FINE', 'ANNUAL_PERMIT', 'CUSTOM_PAYMENT'
  final String name;
  final String? description;
  final double defaultAmount;
  final String billingCycle;
  final bool isCustomAllowed;
  final bool isActive;
  final DateTime createdAt;

  FeeType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.defaultAmount,
    this.billingCycle = 'DAILY',
    this.isCustomAllowed = false,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FeeType.fromJson(Map<String, dynamic> json) {
    return FeeType(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultAmount: (json['default_amount'] as num?)?.toDouble() ?? 0.0,
      billingCycle: json['billing_cycle'] as String? ?? 'DAILY',
      isCustomAllowed: json['is_custom_allowed'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'default_amount': defaultAmount,
      'billing_cycle': billingCycle,
      'is_custom_allowed': isCustomAllowed,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
