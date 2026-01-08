# 🔧 Troubleshooting Guide

Berikut adalah solusi untuk masalah teknis yang sering muncul saat pengembangan **KakiKenyang**.

## 1. Error `INSTALL_FAILED_USER_RESTRICTED`
**Gejala:**
Saat menjalankan `flutter run`, muncul pesan error ini di terminal dan aplikasi gagal terinstall.

**Penyebab:**
Fitur keamanan pada HP Xiaomi/Poco/Redmi (HyperOS/MIUI) memblokir instalasi via ADB.

**Solusi:**
1.  Masuk ke **Settings > Additional Settings > Developer Options**.
2.  Aktifkan **"Install via USB"** (Mungkin butuh login Mi Account).
3.  Jika masih gagal, matikan "MIUI Optimization" (opsional, paling bawah).
4.  Saat `flutter run`, perhatikan layar HP. Jika muncul popup "Install via USB?", segera klik **Install**.

## 2. Google Maps Kosong / Blank
**Gejala:**
Peta muncul tapi hanya kotak abu-abu atau logo Google saja, tidak ada jalanan. Log menampilkan `Authorization failure`.

**Solusi:**
1.  Pastikan API Key di `android/app/src/main/res/values/strings.xml` benar.
2.  Buka **Google Cloud Console**.
3.  Pastikan Package Name `com.sarmagti.kakikenyang` sudah ditambahkan ke *Application Restrictions* API Key tersebut.
4.  Pastikan SHA-1 Fingerprint laptop Anda sudah dimasukkan juga.

## 3. Firebase Auth / OTP Gagal
**Gejala:**
Pesan error `This app is not authorized to use Firebase Authentication`.

**Solusi:**
1.  Cek SHA-1 Debug Key Anda:
    ```bash
    keytool -list -v -keystore "C:\Users\User\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
    ```
2.  Masukkan SHA-1 tersebut ke Firebase Console di bagian *Project Settings*.
3.  Download ulang `google-services.json` dan taruh di `android/app/`.

## 4. Build Error: "Toolchain missing capabilities"
**Gejala:**
Error Gradle yang menyebutkan JRE tidak sesuai.

**Solusi:**
Pastikan di `android/gradle.properties` sudah tersetting:
```properties
org.gradle.java.home=C:/Path/To/Your/JDK-17
```
(Gunakan forward slash `/` bukan backslash `\`).
