class ScanItem {
  final String resiNumber;
  int qty;
  DateTime lastScannedAt;

  ScanItem({
    required this.resiNumber,
    this.qty = 1,
    DateTime? lastScannedAt,
  }) : lastScannedAt = lastScannedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'resiNumber': resiNumber,
      'qty': qty,
      'lastScannedAt': lastScannedAt.toIso8601String(),
    };
  }

  factory ScanItem.fromJson(Map<String, dynamic> json) {
    return ScanItem(
      resiNumber: json['resiNumber'] as String? ?? '',
      qty: json['qty'] as int? ?? 1,
      lastScannedAt: json['lastScannedAt'] != null
          ? DateTime.parse(json['lastScannedAt'] as String)
          : DateTime.now(),
    );
  }

  ScanItem copyWith({
    String? resiNumber,
    int? qty,
    DateTime? lastScannedAt,
  }) {
    return ScanItem(
      resiNumber: resiNumber ?? this.resiNumber,
      qty: qty ?? this.qty,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    );
  }
}
