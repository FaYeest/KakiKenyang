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
    
    Aplikasi ini membutuhkan file konfigurasi rahasia yang tidak disertakan dalam repo.

    *   **Firebase (Android):**
        1.  Buka [Firebase Console](https://console.firebase.google.com/).
        2.  Download `google-services.json`.
        3.  Letakkan file tersebut di folder: `android/app/`.

    *   **Google Maps & Auth Keys:**
        1.  Pergi ke folder `android/app/src/main/res/values/`.
        2.  Duplikat file `strings.xml.example` dan ubah namanya menjadi `strings.xml`.
        3.  Buka `strings.xml` dan isi kredensial Anda:
            *   `client_id`: Web Client ID dari Firebase Auth (Google Sign-In).
            *   `geo_api`: API Key dari Google Cloud Console (pastikan Maps SDK for Android aktif).

    *   **FlutterFire Config (Opsional):**
        Jika `firebase_options.dart` hilang, jalankan:
        ```bash
        flutterfire configure
        ```

4.  **Jalankan Aplikasi**
    Hubungkan perangkat Android (pastikan *USB Debugging* aktif) dan jalankan:
    ```bash
    flutter run
    ```

## ⚠️ Isu Umum (Known Issues)

*   **Xiaomi/Poco Users:** Jika muncul error `INSTALL_FAILED_USER_RESTRICTED`, aktifkan opsi "Install via USB" di Developer Options.
*   **Maps Blank:** Pastikan SHA-1 di Google Cloud Console cocok dengan keystore laptop Anda.
