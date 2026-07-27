# Church Management System — Mobile (Flutter)

Aplikasi mobile jemaat gereja. Berkomunikasi sepenuhnya lewat REST API
Laravel (`church-management-backend`) — tidak ada business logic yang
tersimpan di sisi mobile.

> Status: **Fase Setup Awal** — struktur proyek & arsitektur sudah siap,
> implementasi fitur (Authentication, Jadwal, Warta, Formulir, Donasi, dll)
> menyusul di fase pengembangan berikutnya.

## Stack

| Layer | Tools |
|---|---|
| State management | Riverpod |
| Networking | Dio |
| Routing | GoRouter (`StatefulShellRoute` untuk bottom nav) |
| Auth | Firebase Auth → tukar token ke Laravel Sanctum |
| Push notification | Firebase Cloud Messaging |
| Functional error handling | fpdart (`Either<Failure, T>`) |
| Codegen | freezed, json_serializable, riverpod_generator |

## Arsitektur: Clean Architecture + Feature First

```
lib/
├── main.dart              # entry point: load .env, init SharedPreferences
├── app.dart                # root MaterialApp.router
├── core/                   # infrastruktur lintas fitur
│   ├── config/env/         # baca konfigurasi dari .env
│   ├── theme/               # design tokens: colors, typography, spacing
│   ├── router/              # GoRouter + shell bottom nav
│   ├── network/             # Dio client, endpoint constants, interceptors
│   ├── di/                  # Riverpod provider infrastruktur (Dio, storage)
│   ├── error/                # Failure / AppException + mapper
│   ├── usecase/              # base class UseCase<Type, Params>
│   ├── constants/
│   └── widgets/               # AppButton, AppTextField, state views, dll
└── features/
    └── <feature>/
        ├── data/
        │   ├── datasources/   # remote (Dio) & local (cache) datasource
        │   ├── models/         # DTO + fromJson/toJson (freezed)
        │   └── repositories/   # implementasi repository interface
        ├── domain/
        │   ├── entities/       # model murni, tanpa dependency ke Dio/JSON
        │   ├── repositories/   # abstract repository (kontrak)
        │   └── usecases/        # 1 usecase = 1 aksi bisnis
        └── presentation/
            ├── providers/        # Riverpod providers/notifiers untuk screen ini
            ├── screens/           # halaman (widget page-level)
            └── widgets/            # widget spesifik fitur ini
```

Modul yang sudah disiapkan strukturnya (folder + placeholder screen):
`auth`, `home`, `schedule`, `announcement`, `forms`, `prayer_request`,
`donation`, `directory`, `community`, `finance`, `media`, `profile`, `search`.

### Alur data (arah dependency)

```
presentation → domain ← data
```

`domain` tidak boleh bergantung pada `data` maupun `presentation` (tidak ada
import Dio/Flutter widget di domain layer). `data` mengimplementasikan
kontrak dari `domain`.

## Setup Lokal

1. **Install Flutter** (channel stable, ≥ 3.24) — lihat [flutter.dev](https://flutter.dev).
2. Clone repo & install dependency:
   ```bash
   flutter pub get
   ```
3. Salin konfigurasi environment:
   ```bash
   cp .env.example .env
   # sesuaikan API_BASE_URL ke Laravel API lokal/dev
   ```
4. Jalankan code generation (setelah ada model/provider yang pakai freezed/riverpod_generator):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

### Firebase (untuk fase Authentication & Notifikasi)

Belum dikonfigurasi di fase setup ini. Saat modul Authentication mulai
dikerjakan, tambahkan:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- Panggil `Firebase.initializeApp()` di `main.dart` (sudah ada komentar
  placeholder di sana).

## Coding Standard

- Ikuti [Conventional Commits](https://www.conventionalcommits.org/) untuk pesan commit
  (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`).
- Jalankan `dart format .` dan `flutter analyze` sebelum push.
- Semua kerja dimulai dari branch `develop`, lewat branch `feature/*`,
  `bugfix/*`, `refactor/*`, atau `docs/*`, lalu Pull Request — tidak ada
  commit langsung ke `main`/`develop`.
- Business logic di-service/repository layer, bukan di widget.

## Branching

```
main (produksi, stabil)
  └── develop (integrasi)
        ├── feature/*
        ├── bugfix/*
        ├── refactor/*
        └── docs/*
```

## CI

GitHub Actions (`.github/workflows/flutter_ci.yml`) menjalankan
`dart format --set-exit-if-changed`, `flutter analyze`, dan `flutter test`
di setiap PR ke `develop`/`main`.
