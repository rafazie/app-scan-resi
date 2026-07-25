import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/scan_provider.dart';
import '../widgets/camera_scanner_dialog.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScanProvider>(context, listen: false).loadHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCameraScanSearch() async {
    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CameraScannerDialog(
          title: 'Scan Resi untuk Search History',
          onScanned: (code) {},
        ),
      ),
    );

    if (scannedCode != null && scannedCode.isNotEmpty) {
      _searchController.text = scannedCode;
      if (mounted) {
        Provider.of<ScanProvider>(context, listen: false)
            .setHistorySearchQuery(scannedCode);
      }
    }
  }

  void _exportHistoryCsv() async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final filePath = await scanProvider.exportHistoryCsv();
    if (filePath.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File History CSV tersimpan: $filePath'),
          action: SnackBarAction(
            label: 'Bagikan',
            textColor: Colors.amber,
            onPressed: () {
              Share.share('Export File History Total Resi: $filePath');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    final historyItems = scanProvider.filteredHistoryItems;
    final totalUnique = scanProvider.historyItems.length;
    final totalAllQty =
        scanProvider.historyItems.fold(0, (sum, item) => sum + item.qty);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'List History',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Seluruh no resi tersimpan (Order by Qty DESC)',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export History CSV',
            icon: const Icon(Icons.download, color: Colors.greenAccent),
            onPressed: _exportHistoryCsv,
          ),
          IconButton(
            tooltip: 'Refresh History',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => scanProvider.loadHistory(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---------------- SEARCH HEADER ----------------
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (value) {
                          scanProvider.setHistorySearchQuery(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari No. Resi (Manual / Scan)...',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    scanProvider.setHistorySearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Scan Camera Search Button
                    InkWell(
                      onTap: _openCameraScanSearch,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0EA5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats summary pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Unique Resi: $totalUnique',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      'Total Akumulasi Qty: $totalAllQty',
                      style: const TextStyle(
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Header Table
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F172A),
            child: const Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'No. Resi',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0EA5E9),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Terakhir Scan',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),

          // ---------------- HISTORY LIST (QTY DESC) ----------------
          Expanded(
            child: scanProvider.isLoadingHistory
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                  )
                : historyItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off,
                                size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            Text(
                              scanProvider.historySearchQuery.isNotEmpty
                                  ? 'Tidak ditemukan resi "${scanProvider.historySearchQuery}"'
                                  : 'Belum ada history resi tersimpan',
                              style: const TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: historyItems.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = historyItems[index];
                          final dateStr = DateFormat('dd/MM/yyyy HH:mm')
                              .format(item.lastScannedAt);
                          final isHighest = index == 0;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isHighest
                                    ? const Color(0xFF0EA5E9).withValues(alpha: 0.6)
                                    : Colors.white10,
                                width: isHighest ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // No Resi
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    item.resiNumber,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Total Qty Badge
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0EA5E9)
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: const Color(0xFF0EA5E9)
                                                .withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        '${item.qty}',
                                        style: const TextStyle(
                                          color: Color(0xFF0EA5E9),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Last Scan Time
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    dateStr,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
