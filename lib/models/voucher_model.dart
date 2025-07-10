class Voucher {
  final String id;
  final String code;
  final int discount;
  final int? maxDiscount;
  final int? minOrderValue;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Voucher({
    required this.id,
    required this.code,
    required this.discount,
    this.maxDiscount,
    this.minOrderValue,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['_id'],
      code: json['code'],
      discount: json['discount'],
      maxDiscount: json['maxDiscount'],
      minOrderValue: json['minOrderValue'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'code': code,
      'discount': discount,
      'maxDiscount': maxDiscount,
      'minOrderValue': minOrderValue,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }
} 