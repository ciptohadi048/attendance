# Factory Attendance

A modern industrial HRIS (attendance) app for factory employees, built with
**Flutter + Firebase**. Employees clock in/out with GPS validation and AI face
detection; HRD monitors attendance from an admin dashboard.

> Tugas Mobile — Semester Genap 2025/2026. Theme: *Modern Industrial, Enterprise
> HRIS, Clean Minimal*. Palette: Deep Navy `#0B1D3A`, White, Safety Orange
> `#FF6B35`.

## Tech stack

| Concern           | Choice                                            |
| ----------------- | ------------------------------------------------- |
| Framework         | Flutter (Material 3)                              |
| State management  | Riverpod 3 (`Notifier` / `NotifierProvider`)      |
| Architecture      | Clean Architecture (data / domain / presentation) |
| Backend           | Firebase (Auth, Firestore; Storage + FCM planned) |
| Routing           | go_router with auth + role-based redirects         |
| Local persistence | shared_preferences ("Remember Me", theme)         |

## Architecture

The code follows Clean Architecture so business logic never depends on the UI
or on Firebase. Dependencies point **inward** (presentation → domain ← data):

```
lib/
├── core/                 # cross-cutting: theme, constants, utils, services, errors
│   ├── constants/        # office GPS rules, collection names, prefs keys
│   ├── theme/            # color tokens + ThemeData (dark + light)
│   ├── utils/            # pure validators (unit-tested)
│   ├── services/         # SharedPrefsService
│   └── errors/           # auth error → friendly message mapping
├── domain/               # framework-agnostic core
│   ├── entities/         # AppUser, UserRole
│   └── repositories/     # AuthRepository (abstract interface)
├── data/                 # implementation detail (Firebase lives here)
│   ├── models/           # AppUserModel (Firestore (de)serialization)
│   ├── datasources/      # AuthRemoteDataSource (FirebaseAuth + Firestore)
│   └── repositories/     # AuthRepositoryImpl
├── presentation/
│   ├── providers/        # Riverpod providers = our DI container
│   ├── router/           # go_router config + route constants
│   ├── screens/          # splash, auth, dashboard, admin
│   └── widgets/          # reusable UI (buttons, fields, app bar)
└── main.dart             # composition root: Firebase init + ProviderScope
```

**Dependency rule:** `presentation` and `data` both depend on `domain`; `domain`
depends on nothing. Riverpod wires the concrete `AuthRepositoryImpl` to the
abstract `AuthRepository` that the UI consumes, so the backend is swappable and
testable.

## Features (so far)

- Splash screen with branding animation and bootstrap routing.
- Login with NIK **or** email + password, show/hide password, form validation.
- "Remember Me" via SharedPreferences (pre-fills the saved identifier).
- Forgot Password (email reset link).
- Auth state listener → role-based routing (employee dashboard vs admin shell).
- Persisted dark/light theme toggle.
- Employee dashboard + admin dashboard skeletons.
- Firestore security rules enforcing per-user data isolation.

## Getting started

### Prerequisites
- Flutter 3.29+ (developed on 3.41)
- A Firebase project configured via `flutterfire configure`
  (`lib/firebase_options.dart` + `android/app/google-services.json`)

### First-time backend setup
In the [Firebase console](https://console.firebase.google.com/project/factory-attend-72702):
1. **Authentication** → enable the **Email/Password** sign-in provider.
2. **Firestore Database** → create a database (test mode is fine to start).

Then seed demo accounts and deploy the security rules:

```bash
node tool/seed.mjs                       # creates demo admin + employee
firebase deploy --only firestore:rules   # lock down access
```

### Demo credentials
| Role     | Login              | Password   |
| -------- | ------------------ | ---------- |
| Admin    | `admin@pabrik.com` | `Admin123` |
| Employee | `budi@pabrik.com`  | `Budi1234` |

### Run
```bash
flutter pub get
flutter run
```

### Test
```bash
flutter test
```

## Roadmap
GPS validation (Haversine + geofencing) · selfie capture with ML Kit face
detection · attendance history & filters · FCM notifications · admin KPI charts
& CSV export.
