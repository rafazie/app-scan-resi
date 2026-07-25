App Scan Resi
App Scan Resi adalah aplikasi Flutter untuk memindai nomor resi (barcode/QR), mengelola dokumen hasil scan, dan mengekspor data ke CSV. Dirancang untuk penggunaan cepat di perangkat Android, iOS, web, dan desktop (macOS, Windows, Linux).

Fitur utama

Pindai barcode/QR dengan kamera (mobile_scanner)
Input manual nomor resi
Auto-aggregasi dan history across documents
Ekspor dokumen atau seluruh history ke file CSV
Share hasil ekspor (share_plus)
Prasyarat

Flutter SDK (>= 3.11)
Android Studio / Xcode untuk build ke perangkat mobile
Perangkat atau emulator yang mendukung kamera untuk fitur scan
Instalasi & Menjalankan

Clone repository git clone
Masuk direktori proyek cd "app-scan-resi"
Install dependency flutter pub get
Jalankan pada perangkat/emulator flutter run
Build

Android APK: flutter build apk
iOS (Xcode): flutter build ios
Web: flutter build web
Testing

Jalankan unit/widget tests flutter test
Struktur penting

lib/main.dart — entry point, Provider setup
lib/screens — UI (CreateDocument, History, dll.)
lib/providers/scan_provider.dart — logika scan, penyimpanan, ekspor
lib/services/storage_service.dart — penyimpanan JSON & ekspor CSV
pubspec.yaml — dependencies (mobile_scanner, provider, csv, share_plus)
Catatan

Data dokumen disimpan sebagai JSON pada aplikasi (getApplicationDocumentsDirectory) atau di-memory untuk web.
CSV diekspor ke folder dokumen aplikasi; path ditampilkan di UI setelah ekspor.
Kontribusi

Fork → branch fitur → pull request. Ikuti linting (flutter_lints) bila menambahkan kode.
Lisensi Periksa file LICENSE di repo.

Kontak Buka issue untuk laporan bug atau permintaan fitur.