# Factory Attendance

Aplikasi absensi karyawan pabrik berbasis Flutter + Firebase. Karyawan melakukan clock-in/out dengan validasi GPS dan deteksi wajah via ML Kit. HRD memantau kehadiran lewat dashboard admin.

Tema desain: Modern Industrial, warna utama Deep Navy `#0B1D3A`, White, Safety Orange `#FF6B35`.

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter (Material 3) |
| State Management | Riverpod 3 |
| Arsitektur | Clean Architecture (data / domain / presentation) |
| Backend | Firebase Auth + Firestore |
| Routing | go_router (redirect berdasarkan role) |
| Local Storage | shared_preferences |

## Struktur Folder

```
lib/
├── core/                 # theme, constants, utils, services, errors
│   ├── constants/        # koordinat GPS kantor, nama collection
│   ├── theme/            # color tokens + ThemeData (dark & light)
│   ├── utils/            # validators
│   ├── services/         # SharedPrefsService, LocationService, FaceDetection
│   └── errors/           # mapping error → pesan user-friendly
├── domain/               # entity & repository abstrak
│   ├── entities/         # AppUser, UserRole, AttendanceRecord, GpsStatus
│   └── repositories/     # AuthRepository (interface)
├── data/                 # implementasi Firebase
│   ├── models/           # AppUserModel (serialisasi Firestore)
│   ├── datasources/      # AuthRemoteDataSource
│   └── repositories/     # AuthRepositoryImpl
├── presentation/
│   ├── providers/        # Riverpod providers
│   ├── router/           # konfigurasi go_router
│   ├── screens/          # splash, auth, dashboard, camera, admin
│   └── widgets/          # komponen UI reusable
└── main.dart             # entry point: init Firebase + ProviderScope
```

## Fitur

- Splash screen dengan animasi branding
- Login pakai NIK atau email + password
- "Ingat Saya" (simpan identifier di SharedPreferences)
- Lupa password (kirim link reset via email)
- Routing otomatis berdasarkan role (employee / admin)
- Toggle tema gelap/terang
- Absensi dengan validasi GPS (Haversine + geofencing)
- Selfie + deteksi wajah (ML Kit) saat clock-in/out
- Dashboard karyawan & dashboard admin
- Firestore security rules per-user

## Cara Menjalankan

### Prerequisite
- Flutter 3.29+
- Firebase project yang sudah dikonfigurasi (`flutterfire configure`)


### Akun Demo

| Role | Login | Password |
|------|-------|----------|
| Admin | `admin@pabrik.com` | `Admin123` |
| Karyawan | `budi@pabrik.com` | `Budi1234` |

### Run

```bash
flutter pub get
flutter run
```

### Test

```bash
flutter test
```
