import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document_model.dart';
import '../models/scan_item.dart';

class StorageService {
  static const String _documentsFileName = 'documents_data.json';
  static String? _webMemoryStorage;

  Future<File?> _getLocalFile() async {
    if (kIsWeb) return null;
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/$_documentsFileName');
    } catch (_) {
      return null;
    }
  }

  /// Save or update a document in JSON file storage
  Future<void> saveDocument(DocumentModel document) async {
    try {
      final documents = await loadAllDocuments();
      final index = documents.indexWhere((doc) => doc.id == document.id);
      if (index >= 0) {
        documents[index] = document;
      } else {
        documents.add(document);
      }

      final jsonData = jsonEncode(documents.map((e) => e.toJson()).toList());
      if (kIsWeb) {
        _webMemoryStorage = jsonData;
        return;
      }

      final file = await _getLocalFile();
      if (file != null) {
        await file.writeAsString(jsonData);
      }
    } catch (e) {
      debugPrint('Error saving document to JSON: $e');
    }
  }

  /// Load all document histories from JSON file storage
  Future<List<DocumentModel>> loadAllDocuments() async {
    try {
      if (kIsWeb) {
        if (_webMemoryStorage == null || _webMemoryStorage!.trim().isEmpty) return [];
        final List<dynamic> jsonList = jsonDecode(_webMemoryStorage!);
        return jsonList
            .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final file = await _getLocalFile();
      if (file == null || !await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList
          .map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading documents: $e');
      return [];
    }
  }

  /// Delete a document session if needed
  Future<void> deleteDocument(String id) async {
    try {
      final documents = await loadAllDocuments();
      documents.removeWhere((doc) => doc.id == id);

      final jsonData = jsonEncode(documents.map((e) => e.toJson()).toList());
      if (kIsWeb) {
        _webMemoryStorage = jsonData;
        return;
      }

      final file = await _getLocalFile();
      if (file != null) {
        await file.writeAsString(jsonData);
      }
    } catch (e) {
      debugPrint('Error deleting document: $e');
    }
  }

  /// Get aggregated total resi items from all saved documents, sorted by Qty DESC
  Future<List<ScanItem>> getAggregatedHistory() async {
    final documents = await loadAllDocuments();
    final Map<String, ScanItem> map = {};

    for (var doc in documents) {
      for (var item in doc.items) {
        if (map.containsKey(item.resiNumber)) {
          map[item.resiNumber]!.qty += item.qty;
          if (item.lastScannedAt.isAfter(map[item.resiNumber]!.lastScannedAt)) {
            map[item.resiNumber]!.lastScannedAt = item.lastScannedAt;
          }
        } else {
          map[item.resiNumber] = ScanItem(
            resiNumber: item.resiNumber,
            qty: item.qty,
            lastScannedAt: item.lastScannedAt,
          );
        }
      }
    }

    final result = map.values.toList();
    // Filter / Order by Qty DESC
    result.sort((a, b) => b.qty.compareTo(a.qty));
    return result;
  }

  String _toCsvString(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((field) {
        final str = field.toString();
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          return '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }).join(',');
    }).join('\n');
  }

  /// Export a single document to CSV format string and file path
  Future<String> exportDocumentToCsv(DocumentModel document) async {
    final List<List<dynamic>> rows = [
      ['No Resi', 'Qty', 'Terakhir Scanned']
    ];

    final sortedItems = List<ScanItem>.from(document.items)
      ..sort((a, b) => b.qty.compareTo(a.qty));

    for (var item in sortedItems) {
      rows.add([
        item.resiNumber,
        item.qty,
        item.lastScannedAt.toIso8601String(),
      ]);
    }

    final csvData = _toCsvString(rows);
    if (kIsWeb) return 'data:text/csv;charset=utf-8,$csvData';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${document.id}.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);
      return filePath;
    } catch (_) {
      return '';
    }
  }

  /// Export entire aggregated history to CSV
  Future<String> exportAllHistoryToCsv() async {
    final history = await getAggregatedHistory();
    final List<List<dynamic>> rows = [
      ['No Resi', 'Total Qty', 'Terakhir Scanned']
    ];

    for (var item in history) {
      rows.add([
        item.resiNumber,
        item.qty,
        item.lastScannedAt.toIso8601String(),
      ]);
    }

    final csvData = _toCsvString(rows);
    if (kIsWeb) return 'data:text/csv;charset=utf-8,$csvData';

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/History_Total_Resi.csv';
      final file = File(filePath);
      await file.writeAsString(csvData);
      return filePath;
    } catch (_) {
      return '';
    }
  }
}
