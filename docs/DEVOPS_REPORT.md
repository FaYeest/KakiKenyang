# Laporan Implementasi DevOps & Metodologi Pengembangan - KakiKenyang

**Oleh:** Farras & Team
**Mata Kuliah:** Rekayasa Perangkat Lunak 2 (RPL2)

---

## 1. Pendahuluan

**KakiKenyang** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna menemukan UMKM kuliner di sekitar mereka. Dalam pengembangannya, proyek ini menerapkan prinsip **DevOps** untuk memastikan kecepatan pengiriman fitur, keamanan kode, dan stabilitas aplikasi melalui pemantauan (monitoring) yang berkelanjutan.

## 2. Metodologi Pengembangan: Agile Software Development

Proyek ini dikembangkan menggunakan pendekatan **Agile**, khususnya model iteratif yang fokus pada perbaikan cepat dan adaptasi terhadap perubahan.

### Penerapan Agile dalam Proyek:
1.  **Iterative Development:** Pengembangan dilakukan dalam siklus pendek (sprint) yang fokus pada satu masalah spesifik per waktu (contoh: Sprint 1: Fix Android Build, Sprint 2: Security, Sprint 3: Documentation).
2.  **Continuous Feedback:** Setiap perubahan kode langsung diuji (feedback loop) untuk memastikan tidak ada regresi fitur.
3.  **Adaptive Planning:** Rencana pengembangan menyesuaikan dengan isu yang ditemukan di lapangan (misal: penyesuaian strategi Git saat ditemukan file sensitif).

---

## 3. Siklus DevOps (Development + Operations)

Kami menerapkan siklus DevOps yang mencakup perencanaan, koding, pembangunan, pengujian, rilis, hingga pemantauan.

### A. Plan (Perencanaan)
*   **Objective:** Memperbaiki kompatibilitas JDK, mengamankan kredensial (API Keys), dan standarisasi kode.
*   **Tools:** Analisis error log VS Code dan Flutter Diagnostics.

### B. Code (Pengkodean)
*   **Version Control:** Menggunakan **Git** untuk manajemen versi.
*   **Security Practices:**
    *   Pemisahan *Secrets* dari *Source Code* (menghapus `google-services.json` dan `strings.xml` dari repo publik).
    *   Penerapan `.gitignore` yang ketat.
    *   Penggunaan `git filter-branch` untuk menghapus jejak sensitif dari riwayat commit.
*   **Refactoring:** Pembersihan kode *deprecated* (contoh: migrasi `withOpacity` ke `withValues`, fix `BuildContext` async gaps).

### C. Build (Pembangunan)
*   **Automation:** Menggunakan **Gradle** untuk otomatisasi build Android.
*   **Configuration:** Penyesuaian `build.gradle` untuk mendukung JDK 17 dan Android SDK 35.
*   **Dependency Management:** `flutter pub get` untuk sinkronisasi library pihak ketiga.

### D. Test (Pengujian)
*   **Unit Testing:** Menjalankan `test/widget_test.dart` untuk memastikan logika dasar widget berjalan.
*   **Manual Testing:** Verifikasi fungsi Auth (OTP/Google) langsung pada perangkat fisik (Xiaomi/Poco).

### E. Release & Deploy (Rilis & Deployment)
*   **Versioning:** Manajemen versi aplikasi melalui `pubspec.yaml` (v1.0.0+1).
*   **Direct Deployment:** Instalasi instan ke perangkat via **ADB (Android Debug Bridge)** untuk pengujian *real-environment*.

### F. Monitor (Pemantauan & Operasi)
*   **Log Monitoring:** Pemantauan real-time menggunakan `flutter run` console logs.
*   **Performance Monitoring:** Menggunakan **Flutter DevTools** untuk memantau penggunaan memori (RAM), CPU, dan Frame Rendering Time.

---

## 4. Hasil Pengujian & Monitoring

### Skenario Pengujian
Pengujian dilakukan pada perangkat fisik dengan spesifikasi:
*   **Device:** Xiaomi/Poco (Android 15)
*   **Mode:** Debug Mode

### Hasil Performance Profiling (Flutter DevTools)

Berikut adalah metrik yang dipantau untuk memastikan aplikasi berjalan optimal:

#### 1. CPU Usage (Penggunaan Prosesor)
*   **Idle (Diam):** Penggunaan CPU sangat rendah, menandakan tidak ada *memory leak* atau *background process* yang berat.
*   **Active (Saat Navigasi Peta):** Peningkatan wajar saat merender Google Maps, namun tetap di bawah ambang batas *lag* (jank).

#### 2. Memory (RAM)
*   **Heap Usage:** Dipantau untuk memastikan objek Dart yang tidak terpakai dibersihkan oleh *Garbage Collector* (GC).
*   **Image Caching:** Aset gambar (banner) diload secara efisien.

#### 3. Frame Rendering (FPS)
*   Target: Konsisten di 60 FPS.
*   Hasil: Animasi perpindahan halaman (login ke home) berjalan mulus tanpa *dropped frames* yang signifikan.

---

## 5. Kesimpulan

Penerapan metode **Agile** dan prinsip **DevOps** dalam proyek KakiKenyang telah berhasil:
1.  Meningkatkan stabilitas aplikasi (bebas error build).
2.  Menjamin keamanan data (credentials tidak terekspos).
3.  Memudahkan kolaborasi (dokumentasi lengkap dan struktur repo bersih).
4.  Memberikan wawasan performa melalui monitoring real-time.

Aplikasi ini siap untuk tahap pengembangan fitur selanjutnya (CI/CD Pipeline otomatisasi penuh) dan rilis produksi.
