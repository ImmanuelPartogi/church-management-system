# Church Management System

[![Laravel](https://img.shields.io/badge/Laravel-13.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net)
[![Filament](https://img.shields.io/badge/Filament-5.7-FDAE4B?style=for-the-badge&logo=laravel&logoColor=black)](https://filamentphp.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com)

Platform manajemen gereja terintegrasi yang menggabungkan **REST API & Web Admin Portal berbasis Laravel 13 + Filament v5** dengan **Aplikasi Mobile Jemaat berbasis Flutter**. Sistem ini dirancang untuk mempermudah pengelolaan jemaat, jadwal ibadah, warta digital, formulir pelayanan, donasi transfer bank, permohonan doa, dan transparansi keuangan gereja secara terpusat.

---

## 📋 Daftar Isi

- [Overview](#-overview)
- [Tech Stack](#-tech-stack--versioning)
- [Arsitektur & Structure Project](#-arsitektur--structure-project)
- [Arsitektur Multi-Tenant & Roadmap ADR](#-arsitektur-multi-tenant--roadmap-adr)
- [Dokumentasi Lengkap & Runbook Operasional](#-dokumentasi-lengkap--runbook-operasional)
- [Fitur Utama](#-fitur-utama)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Cara Penggunaan (Usage)](#-cara-penggunaan-usage)
- [Verifikasi Kualitas & Testing](#-verifikasi-kualitas--testing)
- [Alur Kontribusi & Git Workflow](#-alur-kontribusi--git-workflow)

---

## 💡 Overview

**Church Management System** hadir sebagai solusi modern untuk digitalisasi operasional gereja. Sistem ini menerapkan arsitektur *Single Source of Truth* di mana seluruh data dikelola secara terpusat pada server Backend (Laravel) dan diakses secara konsisten oleh pengurus gereja melalui Dashboard Web Admin (Filament) serta jemaat melalui Aplikasi Mobile (Flutter).

### Nilai Utama:
- **Kemudahan Akses Jemaat**: Jemaat dapat mengunduh warta gereja, melihat jadwal ibadah beserta petugasnya, mengajukan permohonan doa, mendaftar pelayanan, dan melihat warta transparansi keuangan dari ponsel.
- **Efisiensi Pengurus Gereja**: Majelis dan sekretariat gereja dapat mengelola data jemaat, mengonfirmasi bukti transfer donasi, menerbitkan warta minggu, serta merespon permohonan doa melalui portal admin web.
- **Keamanan & Skalabilitas**: Menggunakan autentikasi berbasis Laravel Sanctum & Firebase Auth, Spatie RBAC untuk manajemen hak akses, dan struktur Clean Architecture pada aplikasi mobile.

---

## 🛠 Tech Stack & Versioning

Berikut adalah rincian lengkap dependensi dan versi paket yang digunakan secara nyata pada codebase backend (`composer.json`) dan mobile (`pubspec.yaml`):

### Backend & Web Admin (`backend/composer.json`)
| Komponen / Package | Versi Digunakan | Deskripsi Fungsi |
|---|---|---|
| **PHP Runtime** | `^8.4` | Bahasa utama server-side |
| **Laravel Framework** | `^13.8` | Core REST API Framework |
| **Filament Admin Panel** | `^5.7` | Web Admin Portal & CMS Majelis |
| **Laravel Sanctum** | `^4.3` | SPA & Mobile API Token Authentication |
| **Spatie Laravel Permission** | `^8.3` | Role-Based Access Control (RBAC) & Teams Multi-Tenancy |
| **Barryvdh Laravel DomPDF** | `^3.1` | In-Memory PDF Generation & Streaming (Zero Disk Footprint) |
| **Kreait Laravel Firebase** | `^7.2` | Integration Firebase Admin Auth & FCM |
| **Laravel Pint** | `^1.27` | Code Style Formatter |
| **Larastan** | `^3.10` | Static Analysis Tool for PHPStan |
| **PHPUnit** | `^12.5.12` | Automated Unit & Integration Testing (314 Tests Passing) |
| **Laravel Pail / Pao / Tinker** | `^1.2.5` / `^1.0.6` / `^3.0` | CLI Logging & Interactive Shell |

### Mobile Application (`mobile/pubspec.yaml`)
| Komponen / Package | Versi Digunakan | Deskripsi Fungsi |
|---|---|---|
| **Dart SDK** | `>=3.4.0 <4.0.0` (Flutter `3.22+`) | Language & SDK Environment |
| **Flutter Riverpod** | `^2.5.1` (`generator ^2.4.0`, `annotation ^2.3.5`) | State Management & Reactive DI |
| **Dio** | `^5.4.3` (`pretty_dio_logger ^1.3.1`) | HTTP Client Network Layer |
| **GoRouter** | `^14.2.0` | Declarative Routing & Navigation Shell |
| **fpdart** | `^1.1.0` | Functional Programming (`Either<Failure, T>`) |
| **Firebase Auth & Core** | `^5.7.0` / `^3.15.2` (`google_sign_in ^6.2.1`) | Mobile Identity Provider |
| **Firebase Messaging** | `^15.2.10` | Push Notification Listener |
| **Flutter Secure Storage & SharedPref**| `^9.2.2` / `^2.2.3` | Local Encrypted Token & Session Cache |
| **Freezed & JsonSerializable** | `^2.5.5` / `^6.8.0` (`build_runner ^2.4.11`) | Codegen Immutable Models & JSON DTOs |
| **Syncfusion PDF Viewer** | `^26.1.35` | In-app Warta & Sermon PDF Viewer |
| **Table Calendar** | `^3.1.2` | Interactive Calendar for Worship Schedules |
| **UI Kits (Fonts, SVG, Shimmer, Image)** | `google_fonts ^6.2.1`, `flutter_svg ^2.0.10+1`, `shimmer ^3.0.0`, `cached_network_image ^3.3.1` | UI Design System & Smooth Shimmer Effects |

---

## 📁 Arsitektur & Structure Project

Project ini disusun dalam bentuk monorepo terstruktur yang memisahkan kode Backend API, Aplikasi Mobile, dan Dokumentasi Teknis:

```
church-management-system/
├── backend/                     # Laravel 13 API & Filament v5 Admin Web
│   ├── app/
│   │   ├── Enums/               # Enum domain (ApplicationStatus, PrayerStatus, dll)
│   │   ├── Filament/            # Resources & Pages Portal Web Admin (19 Resources)
│   │   ├── Http/
│   │   │   ├── Controllers/Api/V1/ # REST API Controllers (18 Controllers, 41 Active Endpoints)
│   │   │   └── Middleware/      # Custom middleware (Authenticate, Sanitize, ResolveChurchContext)
│   │   ├── Models/              # Eloquent Models & Relationship definitions (23 Models)
│   │   ├── Policies/            # Spatie RBAC Authorization Policies
│   │   ├── Providers/           # Service Providers (App, AdminPanelProvider)
│   │   └── Services/            # Business Logic & Integration Services (FCM, Auth, Reporting)
│   ├── config/                  # Konfigurasi aplikasi, auth, & packages
│   ├── database/                # Database Migrations, Factories, & Seeders
│   ├── routes/                  # Route definitions (api.php, web.php, console.php)
│   └── tests/                   # Automated PHPUnit Test Suites (314 Tests, 1196 Assertions - 100% Green)
│
├── mobile/                      # Aplikasi Mobile Jemaat (Flutter Clean Architecture)
│   ├── android/                 # Native Android wrapper & build setup
│   ├── ios/                     # Native iOS wrapper & build setup
│   ├── lib/
│   │   ├── app/                 # Root App Widget & GoRouter navigation configuration
│   │   ├── core/                # Infrastructure: Network Dio, Storage, Theme, Tenant Scoping
│   │   └── features/            # Feature-first Clean Architecture Modules
│   └── test/                    # Automated Unit & Widget Test Suites (84 Tests - 100% Green)
│
├── docs/                        # Dokumentasi Arsitektur & Operasional Produksi
│   ├── ARCHITECTURE_DECISION_RECORDS.md # Katalog Lengkap ADR 1 s/d ADR 11
│   ├── PRODUCTION_OPERATIONS_RUNBOOK.md # Panduan Deployment, Supervisor, Cron, & Runbook
│   └── KNOWN_LIMITATIONS.md            # Registry Batasan Teknis & Technical Debt
│
├── .github/                     # Workflow CI/CD (Backend & Mobile Workflows)
└── README.md                    # Dokumentasi utama proyek
```

---

## 🏛 Arsitektur Multi-Tenant & Roadmap ADR

Sistem ini menerapkan isolasi multi-tenant tingkat tinggi dengan pengawasan konsolidasi sinode terpusat:

| Milestone / Phase | Keputusan Arsitektural (ADR) | Kapabilitas Kunci | Status |
| :--- | :--- | :--- | :--- |
| **Phase 1E** | **ADR 1**: Strict Tenant Isolation | Trait `BelongsToChurch`, `ChurchScope`, non-fillable `church_id`, `withoutChurch()` macro | ✅ COMPLETED |
| **Phase 2** | **ADR 2**: Spatie Teams Migration | Spatie RBAC dengan scoping `team_id` terikat ke `church_id` | ✅ COMPLETED |
| **Phase 3** | **ADR 3**: Context Resolution | Middleware `ResolveChurchContext` dengan validasi anti-spoofing | ✅ COMPLETED |
| **Phase 4A** | **ADR 4 & 5**: Tenant Management | `ChurchPolicy`, endpoint publik `/churches`, Filament Topbar Switcher | ✅ COMPLETED |
| **Phase 4B** | **ADR 6**: 12-Module Feature Flags | Taksonomi 12 modul, middleware `module:{key}`, `HasModuleAccess` | ✅ COMPLETED |
| **Phase 4C** | **ADR 7**: Mobile Multi-Tenant | `TenantInterceptor`, rekonsiliasi state jemaat multi-membership | ✅ COMPLETED |
| **Phase 5** | **ADR 8**: Async Scoping & Hardening | `TenantAwareJob` zero-leak context teardown, direktori storage partisi | ✅ COMPLETED |
| **Phase 6A** | **ADR 9**: Synod Reporting Engine | `GenerateSynodReportSnapshotJob`, atomic cache locks, metrik helikopter | ✅ COMPLETED |
| **Phase 7** | **ADR 10**: Self-Service Onboarding | Form registrasi mandiri publik, HMAC signed route, approval atomik | ✅ COMPLETED |
| **Phase 8** | **ADR 11**: In-Memory Export Pipeline | Ekspor resmi PDF & CSV, zero disk footprint, dynamic memory restoration | ✅ COMPLETED |

---

## 📚 Dokumentasi Lengkap & Runbook Operasional

Untuk detail spesifikasi teknis dan panduan operasional server produksi, rujuk dokumen berikut:
1. [**Architecture Decision Records Catalog (`docs/ARCHITECTURE_DECISION_RECORDS.md`)**](file:///docs/ARCHITECTURE_DECISION_RECORDS.md): Spesifikasi arsitektural lengkap ADR 1 hingga ADR 11.
2. [**Production Operations & Deployment Runbook (`docs/PRODUCTION_OPERATIONS_RUNBOOK.md`)**](file:///docs/PRODUCTION_OPERATIONS_RUNBOOK.md): Panduan instalasi Ubuntu, konfigurasi Supervisor queue worker daemon, pengaturan Cron scheduler, dan mitigasi tanggap darurat.
3. [**Known Limitations & Technical Debt Registry (`docs/KNOWN_LIMITATIONS.md`)**](file:///docs/KNOWN_LIMITATIONS.md): Dokumentasi transparan batasan teknis (profiling N+1 query rentang 50–300 gereja, circuit breaker threshold 300 gereja untuk ekspor PDF).

---

## ✨ Fitur Utama

Sistem menyediakan fungsi terpadu untuk pengurus gereja dan jemaat:

| Modul Fitur | Aplikasi Mobile (Jemaat) | Admin Web (Filament) |
|---|---|---|
| **Autentikasi & Akun** | Login via Firebase/Email, Manajemen Session, Profil Jemaat | Login Admin, RBAC Role Management (Admin, Majelis, Member) |
| **Jadwal Ibadah** | Tampilan Jadwal Ibadah Minggu/Kategori, Kalender Petugas | Kelola Jadwal Ibadah & Penugasan Petugas (Worship Officers) |
| **Warta Digital** | Lihat Warta Terbaru, Unduh Bulletin PDF Warta Minggu | Terbitkan & Upload PDF Warta Mingguan |
| **Formulir Pelayanan** | Pengajuan Sakramen (Baptis, Sidi, Nikah) + Upload Dokumen | Verifikasi, Review Document, & Update Status Pengajuan |
| **Donasi Transfer Bank** | Info Rekening Gereja, Upload Bukti Transfer Manual, Riwayat Donasi | Konfirmasi Pembayaran, Approval/Rejection Bukti Transfer |
| **Permohonan Doa** | Pengajuan Doa Pastoral (Public/Private), Lihat Status Doa | Tanggapi Permohonan Doa & Catatan Pendampingan Pastoral |
| **Transparansi Keuangan**| Ringkasan Laporan Laba-Rugi / Pemasukan-Pengeluaran Gereja | Kelola Chart of Accounts (COA) & Transaksi Keuangan |
| **Direktori & Pengurus**| Cari Kontak Jemaat, Sektor, Resort, & Daftar Pengurus Gereja | Kelola Master Data Jemaat, Sektor, Resort, & Majelis |
| **Notifikasi FCM** | Receiver Push Notification Pesan Gereja & Update Pengajuan | Kirim Pengumuman Broadcast FCM ke Seluruh Device Jemaat |
| **Multi-Tenant & Switcher** | Auto-switch tenant aktif & modal prompt multi-membership | Topbar Tenant Switcher & isolasi Spatie Teams |
| **Pendaftaran Mandiri (Onboarding)** | Pendaftaran gereja publik & verifikasi email HMAC signed route | Queue review pendaftaran & approval atomik Super Admin |
| **Dashboard Sinode HKBP** | - | Konsolidasi data seluruh gereja, metrik helikopter, komparasi |
| **Ekspor Laporan Resmi (PDF/CSV)** | - | Ekspor in-memory PDF dokumen resmi & CSV UTF-8 BOM |

---

## ⚡ Prerequisites

Sebelum memulai instalasi, pastikan lingkungan pengembangan Anda telah memenuhi kebutuhan perangkat lunak berikut:

### Perangkat Lunak Utama
- **PHP**: Versi `>= 8.4` (dengan ekstensi `pdo`, `pdo_mysql`, `pdo_sqlite` (untuk CLI testing), `mbstring`, `openssl`, `curl`, `gd`)
- **Composer**: Versi `>= 2.7`
- **Node.js**: Versi `>= 20.x` & **npm**: Versi `>= 10.x`
- **Database Server**: MySQL `>= 8.0` atau MariaDB `>= 10.6`
- **Flutter SDK**: Versi `>= 3.22.0` (Dart SDK `>= 3.4.0`)
- **Android Studio / Xcode**: Untuk menjalankan emulator atau build binary mobile

---

## 📦 Instalasi & Setup

Petunjuk instalasi berikut dapat diikuti langkah demi langkah tanpa asumsi konfigurasi awal.

### 1. Clone Repository
```bash
git clone https://github.com/ImmanuelPartogi/church-management-system.git
cd church-management-system
```

### 2. Setup Backend (Laravel API + Filament Admin)
```bash
# Masuk ke direktori backend
cd backend

# Install dependensi PHP via Composer
composer install

# Salin file env eksekusi dan sesuaikan konfigurasi database
cp .env.example .env

# Generate Application Key
php artisan key:generate

# Konfigurasikan koneksi MySQL di file .env:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=church_management
# DB_USERNAME=root
# DB_PASSWORD=yourpassword

# Jalankan migrasi database beserta data awal (seeders)
php artisan migrate --seed

# [Wajib pada Update/Deployment ke Phase 4B+]
# Backfill provisioning modul default (12 modul) untuk seluruh tenant legacy yang belum memiliki record modul:
php artisan churches:backfill-modules
# (Opsional: gunakan --dry-run untuk simulasi tanpa menulis ke database, atau --church=<id> untuk target spesifik)

# [Wajib pada Update/Deployment ke Phase 5+ (Queue Worker Daemon)]
# Broadcast notifikasi FCM dan pemrosesan latar belakang kini berjalan secara asinkron.
# Pastikan worker berjalan terus-menerus di server produksi:
php artisan queue:work --tries=3 --backoff=15,60,300

# Install dependensi frontend & build asset admin panel
npm install
npm run build
```

### 3. Setup Mobile (Flutter App)
```bash
# Masuk ke direktori mobile dari root project
cd ../mobile

# Install dependensi Flutter packages
flutter pub get

# Salin file konfigurasi environment mobile
cp .env.example .env

# Jalankan code generator (Freezed & Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

---

## 🚀 Cara Penggunaan (Usage)

### Menjalankan Server Backend & Web Admin Local
Di dalam folder [`backend/`](file:///backend):
```bash
# Menggunakan command bawaan script dev (menjalankan server, queue worker, & vite secara paralel)
composer run dev

# ATAU menjalankan server HTTP Laravel secara terpisah:
php artisan serve
```
- **Portal Web Admin Filament**: Akses melalui browser di `http://127.0.0.1:8000/admin`
- **REST API Base Endpoint**: `http://127.0.0.1:8000/api/v1`

### ⚙️ Background Queue Worker (Prasyarat Wajib Produksi Phase 5+)

Mulai Phase 5, pengiriman push broadcast pengumuman (`SendChurchAnnouncementBroadcastJob`) dan proses domain latar belakang lainnya diproses secara asinkron di antrean. **Jika worker daemon tidak berjalan di server produksi, job akan tertahan di database dan notifikasi tidak akan terkirim ke jemaat.**

#### Menjalankan Worker di Lingkungan Lokal
```bash
cd backend
php artisan queue:work
```

#### Menjalankan Worker di Produksi (Supervisor Daemon)
Buat file konfigurasi Supervisor pada `/etc/supervisor/conf.d/church-cms-worker.conf`:
```ini
[program:church-cms-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/church-management-system/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/log/supervisor/church-cms-worker.log
stopwaitsecs=3600
```
Aktifkan konfigurasi:
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start church-cms-worker:*
```

#### Monitoring & Troubleshooting Antrean
```bash
# Memeriksa ukuran & status antrean:
php artisan queue:monitor default

# Melihat status worker supervisor:
sudo supervisorctl status church-cms-worker:*

# Memeriksa log kegagalan permanen (failed jobs):
php artisan queue:failed

# Mencoba ulang seluruh job yang gagal:
php artisan queue:retry all

# Menghapus job yang gagal:
php artisan queue:flush
```

#### Menjalankan Laravel Scheduler di Produksi (Cron Job)
Sistem memiliki tugas terjadwal otomatis (*scheduled tasks*) yang didefinisikan di `routes/console.php`:
- `church-registrations:prune-stale --days=7`: Pembersihan harian (pukul 02:00) pendaftaran mandiri yang tidak diverifikasi $>7$ hari untuk melepaskan slug ke *available pool*.
- `synod:generate-report`: Pembuatan snapshot agregat laporan sinode lintas-gereja harian (pukul 00:05).

Agar seluruh tugas terjadwal berjalan otomatis di server produksi, tambahkan satu baris cron pada user web server (`crontab -e -u www-data`):
```cron
* * * * * cd /var/www/church-management-system/backend && php artisan schedule:run >> /dev/null 2>&1
```

Memeriksa daftar dan jadwal tugas otomatis:
```bash
php artisan schedule:list
```

### Menjalankan Aplikasi Mobile Flutter
Di dalam folder [`mobile/`](file:///e:/Nero/church-management-system/mobile):
```bash
# Memeriksa kesiapan device/emulator yang terhubung
flutter devices

# Menjalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

---

## 🧪 Verifikasi Kualitas & Testing

Setiap perubahan kode wajib lulus pemeriksaan static analysis dan automated testing sebelum di-merge.

### Pemeriksaan Backend (Laravel)
```bash
cd backend

# Menjalankan Linter / Code Formatter (Laravel Pint)
vendor/bin/pint --test

# Menjalankan Static Analysis (Larastan)
vendor/bin/phpstan analyse --memory-limit=512M

# Menjalankan Automated Unit & Integration Tests (PHPUnit)
php artisan test
```
*Status Terkini*: **314 tests, 1196 assertions, 0 failures (100% Green)**. PHPUnit menggunakan koneksi SQLite in-memory secara default (`phpunit.xml`). Pastikan ekstensi `pdo_sqlite` aktif pada PHP CLI Anda.

### Pemeriksaan Mobile (Flutter)
```bash
cd mobile

# Menjalankan Linter (Flutter Analyze)
flutter analyze

# Memeriksa Format Kode Dart
dart format --output=none --set-exit-if-changed .

# Menjalankan Unit & Widget Tests
flutter test
```
*Status Terkini*: **84 tests passed, 0 failures (100% Green)**. Seluruh interaksi jaringan dimock menggunakan Mocktail dan Fake Async.

---

## 🤝 Alur Kontribusi & Git Workflow

Pengembangan project ini mengikuti standar **Git Flow & Conventional Commits**:

### Skema Branching
```
main (produksi, stabil, protected)
  └── develop (integrasi, protected)
        ├── feature/*   (fitur baru)
        ├── bugfix/*    (perbaikan bug)
        ├── refactor/*  (restrukturisasi kode)
        └── docs/*      (pembaruan dokumentasi)
```

### Aturan Kontribusi
1. Selalu buat branch baru yang diturunkan dari `develop` (contoh: `feature/warta-pdf-viewer`).
2. Jangan pernah melakukan commit langsung ke branch `main` atau `develop`.
3. Gunakan standar pesan commit [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat: menambah modul filter jadwal ibadah`
   - `fix: memperbaiki error parser date pada warta`
   - `docs: memperbarui petunjuk instalasi backend`
4. Buat **Pull Request (PR)** ke `develop` dan pastikan seluruh workflow CI (GitHub Actions) lulus 100% sebelum meminta review.
