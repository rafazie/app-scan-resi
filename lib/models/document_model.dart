import 'scan_item.dart';

class DocumentModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<ScanItem> items;

  DocumentModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.items,
  });

  int get totalQty => items.fold(0, (sum, item) => sum + item.qty);
  int get totalUniqueResi => items.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Dokumen Tanpa Judul',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ScanItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DocumentModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<ScanItem>? items,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
