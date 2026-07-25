# App Scan Resi

Aplikasi Flutter untuk memindai nomor resi (barcode/QR), mengelola dokumen hasil scan, dan mengekspor data ke CSV. Dirancang untuk penggunaan cepat di perangkat Android, iOS, web, dan desktop (macOS, Windows, Linux).

---

## ✨ Fitur Utama

- 📷 **Pindai Barcode/QR** — Scan nomor resi langsung menggunakan kamera perangkat via `mobile_scanner`
- ✏️ **Input Manual** — Tambahkan nomor resi secara manual tanpa kamera
- 📄 **Manajemen Dokumen** — Buat dan kelola dokumen kumpulan hasil scan
- 📊 **Ekspor CSV** — Ekspor dokumen aktif atau seluruh history ke file `.csv`
- 📤 **Share Hasil** — Bagikan file hasil ekspor via aplikasi lain menggunakan `share_plus`
- 🕐 **History** — Lihat riwayat semua dokumen scan yang pernah dibuat

---

## 🛠️ Tech Stack

| Paket | Versi | Fungsi |
|---|---|---|
| `mobile_scanner` | ^7.4.0 | Scan barcode/QR via kamera |
| `provider` | ^6.1.5 | State management |
| `csv` | ^8.0.0 | Generate file CSV |
| `share_plus` | ^13.3.0 | Share file ke aplikasi lain |
| `path_provider` | ^2.1.6 | Akses direktori penyimpanan |
| `google_fonts` | ^8.2.0 | Tipografi (Inter) |
| `intl` | ^0.20.3 | Format tanggal & waktu |

---

## 📋 Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.11 (Dart SDK `^3.11.5`)
- Android Studio / Xcode untuk build ke perangkat mobile
- Perangkat atau emulator dengan dukungan kamera untuk fitur scan

---

## 🚀 Instalasi & Menjalankan

```bash
# 1. Clone repository
git clone https://github.com/<username>/app-scan-resi.git

# 2. Masuk ke direktori proyek
cd app-scan-resi

# 3. Install dependencies
flutter pub get

# 4. Jalankan pada perangkat/emulator
flutter run
```

---

## 📦 Build

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`
> File APK juga disalin ke folder `release/` secara otomatis. Lihat [`release/README.md`](release/README.md) untuk panduan lengkap.

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows / Linux / macOS
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

---

## 🧪 Testing

```bash
flutter test
```

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                        # Entry point & Provider setup
├── models/
│   ├── document_model.dart          # Model data dokumen
│   └── scan_item.dart               # Model data item hasil scan
├── providers/
│   └── scan_provider.dart           # Logika scan, penyimpanan & ekspor
├── screens/
│   ├── home_screen.dart             # Shell navigasi utama (bottom nav)
│   ├── create_document_screen.dart  # Layar buat dokumen & scan resi
│   └── history_screen.dart          # Layar riwayat dokumen
├── services/
│   ├── storage_service.dart         # Penyimpanan JSON & ekspor CSV
│   └── audio_service.dart           # Feedback audio saat scan
└── widgets/                         # Widget reusable
```

---

## 💾 Penyimpanan Data

- Data dokumen disimpan dalam format **JSON** di direktori dokumen aplikasi (`getApplicationDocumentsDirectory`).
- Untuk platform **web**, data disimpan secara in-memory (tidak persisten antar sesi).
- File **CSV** hasil ekspor disimpan di direktori dokumen aplikasi; path file ditampilkan di UI setelah ekspor berhasil.

---

## 🤝 Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b fitur/nama-fitur`)
3. Commit perubahan (`git commit -m 'feat: tambahkan fitur X'`)
4. Push ke branch (`git push origin fitur/nama-fitur`)
5. Buka Pull Request

> Pastikan kode mengikuti aturan linting (`flutter_lints`) sebelum membuat PR.

---

## 📄 Lisensi

Lisensi proyek ini tersedia di file [`LICENSE`](LICENSE).

---

## 📬 Kontak

Buka [issue](../../issues) untuk laporan bug atau permintaan fitur baru.