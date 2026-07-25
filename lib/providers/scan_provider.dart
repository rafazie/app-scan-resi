import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/document_model.dart';
import '../models/scan_item.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';

class ScanProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  DocumentModel? _currentDocument;
  List<ScanItem> _historyItems = [];
  String _historySearchQuery = '';
  bool _isLoadingHistory = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  DocumentModel? get currentDocument => _currentDocument;
  List<ScanItem> get historyItems => _historyItems;
  String get historySearchQuery => _historySearchQuery;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get lastScannedCode => _lastScannedCode;

  /// Returns items for current document, sorted by Qty DESC
  List<ScanItem> get sortedCurrentItems {
    if (_currentDocument == null) return [];
    final items = List<ScanItem>.from(_currentDocument!.items);
    items.sort((a, b) => b.qty.compareTo(a.qty));
    return items;
  }

  /// Filtered history items by search query (sorted by Qty DESC)
  List<ScanItem> get filteredHistoryItems {
    if (_historySearchQuery.trim().isEmpty) {
      return _historyItems;
    }
    final query = _historySearchQuery.trim().toLowerCase();
    return _historyItems
        .where((item) => item.resiNumber.toLowerCase().contains(query))
        .toList();
  }

  ScanProvider() {
    startNewDocument();
    loadHistory();
  }

  /// Start a new document (Auto Clear active list without deleting saved files)
  void startNewDocument() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(now);
    _currentDocument = DocumentModel(
      id: 'DOC_$dateStr',
      title: 'Dokumen $dateStr',
      createdAt: now,
      items: [],
    );
    _lastScannedCode = null;
    notifyListeners();
  }

  /// Process scanned barcode/QR code
  Future<bool> processScannedCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return false;

    // Debounce scan (prevent duplicate scans within 1.2 seconds)
    final now = DateTime.now();
    if (_lastScannedCode == code && _lastScanTime != null) {
      final diff = now.difference(_lastScanTime!).inMilliseconds;
      if (diff < 1200) {
        return false;
      }
    }

    _lastScannedCode = code;
    _lastScanTime = now;

    if (_currentDocument == null) {
      startNewDocument();
    }

    final items = List<ScanItem>.from(_currentDocument!.items);
    final index = items.indexWhere((item) => item.resiNumber == code);

    if (index >= 0) {
      // Barcode/QR exists -> Increment Qty by 1
      items[index] = items[index].copyWith(
        qty: items[index].qty + 1,
        lastScannedAt: now,
      );
    } else {
      // New Barcode/QR -> Add to list with Qty = 1
      items.add(ScanItem(
        resiNumber: code,
        qty: 1,
        lastScannedAt: now,
      ));
    }

    _currentDocument = _currentDocument!.copyWith(items: items);

    // Audio / Haptic feedback
    AudioService.playScanSound();

    notifyListeners();

    // Auto save scan result to JSON file storage
    await _storageService.saveDocument(_currentDocument!);
    
    // Refresh history
    await loadHistory();

    return true;
  }

  /// Update item quantity manually
  Future<void> updateItemQty(String resiNumber, int newQty) async {
    if (_currentDocument == null) return;

    final items = List<ScanItem>.from(_currentDocument!.items);
    final index = items.indexWhere((item) => item.resiNumber == resiNumber);

    if (index >= 0) {
      if (newQty <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(qty: newQty);
      }
      _currentDocument = _currentDocument!.copyWith(items: items);
      notifyListeners();

      await _storageService.saveDocument(_currentDocument!);
      await loadHistory();
    }
  }

  /// Remove item from active document list
  Future<void> removeItem(String resiNumber) async {
    if (_currentDocument == null) return;
    final items = List<ScanItem>.from(_currentDocument!.items);
    items.removeWhere((item) => item.resiNumber == resiNumber);
    _currentDocument = _currentDocument!.copyWith(items: items);
    notifyListeners();

    await _storageService.saveDocument(_currentDocument!);
    await loadHistory();
  }

  /// Load accumulated history across all documents (ordered by Qty DESC)
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    _historyItems = await _storageService.getAggregatedHistory();

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Set history search query
  void setHistorySearchQuery(String query) {
    _historySearchQuery = query;
    notifyListeners();
  }

  /// Export current active document to CSV
  Future<String> exportCurrentDocumentCsv() async {
    if (_currentDocument == null) return '';
    return await _storageService.exportDocumentToCsv(_currentDocument!);
  }

  /// Export all history to CSV
  Future<String> exportHistoryCsv() async {
    return await _storageService.exportAllHistoryToCsv();
  }
}
