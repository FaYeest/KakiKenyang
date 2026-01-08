# 🚀 Getting Started with KakiKenyang

Panduan ini akan membantu Anda menjalankan proyek **KakiKenyang** di mesin lokal Anda.

## 📋 Prasyarat (Prerequisites)

Sebelum memulai, pastikan Anda telah menginstal:

1.  **Flutter SDK** (Versi stable terbaru, minimal 3.x).
2.  **Java Development Kit (JDK) 17**.
    *   Proyek ini dikonfigurasi untuk menggunakan JDK 17.
    *   Pastikan environment variable `JAVA_HOME` mengarah ke JDK 17.
3.  **Android Studio** (dengan Android SDK Command-line Tools dan CMake).
4.  **VS Code** (Rekomendasi text editor).

## 🛠️ Instalasi & Setup

1.  **Clone Repository**
    ```bash
    git clone https://github.com/username/kakikenyang.git
    cd kakikenyang
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase & Google Maps**
    *   **Android:**
        *   Pastikan file `android/app/google-services.json` yang valid sudah ada (unduh dari Firebase Console).
        *   Package Name: `com.sarmagti.kakikenyang`.
        *   Tambahkan SHA-1 Debug Keystore Anda ke Firebase Console.
    *   **Maps API:**
        *   Pastikan API Key di `android/app/src/main/res/values/strings.xml` sudah di-whitelist untuk package `com.sarmagti.kakikenyang`.

4.  **Jalankan Aplikasi**
    Hubungkan perangkat Android (pastikan *USB Debugging* aktif) dan jalankan:
    ```bash
    flutter run
    ```

## ⚠️ Isu Umum (Known Issues)

*   **Xiaomi/Poco Users:** Jika muncul error `INSTALL_FAILED_USER_RESTRICTED`, aktifkan opsi "Install via USB" di Developer Options.
*   **Maps Blank:** Pastikan SHA-1 di Google Cloud Console cocok dengan keystore laptop Anda.
