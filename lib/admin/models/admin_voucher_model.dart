class Voucher {
  final String id;
  final String code;
  final String type; // 'percent' hoặc 'fixed'
  final int value;
  final int minOrderAmount;
  final int maxDiscount;
  final DateTime? expiredAt;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    required this.maxDiscount,
    this.expiredAt,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      value: json['value'] ?? 0,
      minOrderAmount: json['minOrderAmount'] ?? 0,
      maxDiscount: json['maxDiscount'] ?? 100000,
      expiredAt: json['expiredAt'] != null ? DateTime.tryParse(json['expiredAt']) : null,
      isActive: json['isActive'] ?? json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscount': maxDiscount,
      'expiredAt': expiredAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
} 