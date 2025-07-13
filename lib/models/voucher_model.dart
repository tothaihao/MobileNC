class Voucher {
  final String id;
  final String code;
  final String type; // "percent" or "fixed"
  final int value;
  final int? minOrderAmount;
  final int? maxDiscount;
  final DateTime? expiredAt;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscount,
    this.expiredAt,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'],
      code: json['code'],
      type: json['type'],
      value: json['value'],
      minOrderAmount: json['minOrderAmount'],
      maxDiscount: json['maxDiscount'],
      expiredAt: json['expiredAt'] != null ? DateTime.parse(json['expiredAt']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
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

extension VoucherX on Voucher {
  String get displayValue =>
      type == 'percent' ? '$value%' : '$value VNĐ';
}
