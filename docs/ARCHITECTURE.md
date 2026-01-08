# 🏗️ Architecture & Project Structure

Proyek **KakiKenyang** menggunakan pola arsitektur **MVVM (Model-View-ViewModel)** yang disederhanakan dengan **Provider** untuk State Management.

## 📂 Struktur Folder (`lib/`)

```
lib/
├── constant/           # Konstanta global (API keys, static strings)
├── controller/         # Logika bisnis dan State Management
│   ├── provider/       # ChangeNotifier classes (State UI)
│   │   ├── authProvider/   # State untuk Login/OTP/Google Auth
│   │   └── services/       # Service logic (memisahkan UI dari Data)
│   └── services/       # Interaksi langsung dengan Firebase/API
│       ├── authServices/   # FirebaseAuth logic
│       ├── userServices/   # Firestore user data logic
│       └── imageServices/  # Image picker logic
├── models/             # Data Models (Dart classes untuk parsing JSON/Firestore)
├── utils/              # Utility functions, styles (Colors, TextStyles), Themes
├── view/               # UI Screens (Widget)
│   ├── account/        # Halaman Profil User
│   ├── authScreen/     # Login, OTP, Register
│   ├── cart/           # Keranjang Belanja
│   ├── home/           # Halaman Utama (Banner, Rekomendasi)
│   ├── map/            # Google Maps Integration
│   ├── navigationBar/  # Bottom Nav Logic
│   ├── search/         # Pencarian Makanan
│   └── signin/         # (Legacy/Alternative signin views)
└── main.dart           # Entry point
```

## 🧩 Key Components

### 1. State Management (Provider)
Aplikasi ini menggunakan `MultiProvider` di `main.dart` untuk menyuntikkan state ke seluruh aplikasi:
*   `MobileAuthProvider`: Menangani state input nomor HP, loading, dan timer OTP.
*   `GoogleSignInService`: Menangani state login Google.
*   `MapState`: Menangani logika pemilihan marker dan data UMKM di peta.
*   `ThemeNotifier`: Menangani perubahan tema (Dark/Light Mode).

### 2. Services
Layer ini menangani komunikasi data agar UI tetap bersih:
*   `MobileAuthServices`: Static methods untuk `verifyPhoneNumber`, `signInWithCredential`.
*   `UserServices`: Mengambil atau menyimpan data user ke koleksi `buyers` di Firestore.

### 3. Google Maps Integration
*   Menggunakan `google_maps_flutter`.
*   Style peta berubah dinamis mengikuti tema aplikasi (Dark/Light).
*   Mengambil data lokasi UMKM secara *real-time* dari koleksi `live_locations` di Firestore.

## 🔄 Alur Data (Data Flow)

1.  **User Action** (misal: klik tombol "Kirim OTP") di `View`.
2.  **Provider** dipanggil (`context.read<MobileAuthProvider>...`).
3.  **Service** dieksekusi (`MobileAuthServices.receiveOTP`).
4.  **Firebase Auth** merespons.
5.  **Provider** mengupdate state (misal: `isLoading = false`).
6.  **UI** di-rebuild otomatis (karena `Consumer` atau `context.watch`).
