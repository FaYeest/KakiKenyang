# 🚀 CI/CD Pipeline Design - KakiKenyang

Dokumen ini menjelaskan rancangan pipeline **Continuous Integration (CI)** dan **Continuous Deployment (CD)** untuk proyek KakiKenyang menggunakan **GitHub Actions**.

Tujuan pipeline ini adalah untuk mengotomatisasi pengujian kode dan pembuatan aplikasi (build) setiap kali ada perubahan kode, sehingga kualitas perangkat lunak tetap terjaga.

---

## 1. Workflow Overview

Pipeline ini dirancang untuk berjalan secara otomatis pada event berikut:
*   **Push** ke branch `main`.
*   **Pull Request** ke branch `main`.

### Tahapan Pipeline (Stages):
1.  **Setup Environment:** Menyiapkan Ubuntu VM, Java 17, dan Flutter SDK.
2.  **Linting (Analisis Kode):** Memeriksa kesalahan sintaks dan gaya penulisan kode (`flutter analyze`).
3.  **Testing (Pengujian):** Menjalankan unit test (`flutter test`).
4.  **Building (Pembangunan):** Membuild file APK Android (hanya jika test lolos).
5.  **Release (Penyebaran):** Mengunggah APK ke GitHub Releases (Tahap Lanjutan).

---

## 2. Implementasi GitHub Actions (`.github/workflows/flutter_ci.yml`)

Berikut adalah kode konfigurasi pipeline yang siap digunakan:

```yaml
name: Flutter CI/CD

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    name: Build & Test
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout Source Code
      - uses: actions/checkout@v4

      # 2. Setup Java 17 (Required for Gradle)
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          distribution: 'temurin'
          java-version: '17'

      # 3. Setup Flutter SDK
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      # 4. Install Dependencies
      - name: Install Dependencies
        run: flutter pub get

      # 5. Linting (Cek Kualitas Kode)
      - name: Analyze Code
        run: flutter analyze

      # 6. Unit Testing
      - name: Run Tests
        run: flutter test

      # 7. Create google-services.json Dummy (Untuk Build CI)
      #    Catatan: Di Production, gunakan GitHub Secrets untuk menyimpan isi file asli.
      - name: Create Dummy google-services.json
        run: echo '{}' > android/app/google-services.json

      # 8. Build APK (Hanya berjalan jika Test lolos)
      - name: Build APK
        run: flutter build apk --debug

      # 9. Upload Artifact (Simpan APK hasil build)
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: app-debug
          path: build/app/outputs/flutter-apk/app-debug.apk
```

---

## 3. Penjelasan Keamanan (Security in CI/CD)

Karena proyek ini menggunakan file rahasia (`google-services.json` dan `strings.xml`) yang tidak di-upload ke GitHub, pipeline CI/CD memerlukan penanganan khusus:

1.  **GitHub Secrets:** Isi file rahasia harus disimpan di menu *Settings > Secrets* pada repositori GitHub.
2.  **Inject Secrets:** Pada saat pipeline berjalan, script akan mengambil isi Secrets tersebut dan membuat file aslinya sementara di dalam server build.
3.  **Dummy File:** Untuk pengujian sederhana (seperti di atas), kita bisa membuat file dummy (kosong) agar proses `gradle build` tidak error, meskipun fitur Firebase tidak akan jalan di APK hasil build tersebut.

## 4. Manfaat Penerapan
*   **Deteksi Error Dini:** Jika ada kode yang salah, `flutter analyze` akan langsung memberitahu via email.
*   **Kualitas Terjaga:** Fitur baru tidak akan merusak fitur lama karena dicek oleh `flutter test`.
*   **Efisiensi Waktu:** Tidak perlu build manual di laptop setiap kali ingin membagikan APK ke tim.
