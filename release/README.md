# Folder Release APK

Folder ini disiapkan untuk menampung file hasil build Android APK (`app-release.apk`).

### Cara Meng-generate File APK:
1. Pastikan **Android SDK** terinstall di perangkat Anda (dapat diinstall melalui [Android Studio](https://developer.android.com/studio)).
2. Apabila Android SDK sudah diinstall di lokasi kustom, daftarkan lokasi ke Flutter:
   ```bash
   flutter config --android-sdk "C:\Users\<Username>\AppData\Local\Android\Sdk"
   ```
3. Jalankan perintah build APK:
   ```bash
   flutter build apk --release
   ```
4. File APK yang telah selesai dibuat otomatis berada di lokasi:
   `build\app\outputs\flutter-apk\app-release.apk`
   dan disalin ke folder `release\` ini.
