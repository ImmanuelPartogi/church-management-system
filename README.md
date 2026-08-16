# Church Management System

[![Laravel](https://img.shields.io/badge/Laravel-13.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net)
[![Filament](https://img.shields.io/badge/Filament-5.7-FDAE4B?style=for-the-badge&logo=laravel&logoColor=black)](https://filamentphp.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

Platform manajemen gereja terintegrasi yang menggabungkan **REST API & Web Admin Portal berbasis Laravel 13 + Filament v5** dengan **Aplikasi Mobile Jemaat berbasis Flutter**. Sistem ini dirancang untuk mempermudah pengelolaan jemaat, jadwal ibadah, warta digital, formulir pelayanan, donasi transfer bank, permohonan doa, dan transparansi keuangan gereja secara terpusat.

---

## 📋 Daftar Isi

- [Overview](#-overview)
- [Tech Stack](#-tech-stack)
- [Arsitektur & Structure Project](#-arsitektur--structure-project)
- [Fitur Utama](#-fitur-utama)
- [Prerequisites](#-prerequisites)
- [Instalasi & Setup](#-instalasi--setup)
- [Cara Penggunaan (Usage)](#-cara-penggunaan-usage)
- [Verifikasi Kualitas & Testing](#-verifikasi-kualitas--testing)
- [Alur Kontribusi & Git Workflow](#-alur-kontribusi--git-workflow)
- [Lisensi](#-lisensi)

---

## 💡 Overview

**Church Management System** hadir sebagai solusi modern untuk digitalisasi operasional gereja. Sistem ini menerapkan arsitektur *Single Source of Truth* di mana seluruh data dikelola secara terpusat pada server Backend (Laravel) dan diakses secara konsisten oleh pengurus gereja melalui Dashboard Web Admin (Filament) serta jemaat melalui Aplikasi Mobile (Flutter).

### Nilai Utama:
- **Kemudahan Akses Jemaat**: Jemaat dapat mengunduh warta gereja, melihat jadwal ibadah beserta petugasnya, mengajukan permohonan doa, mendaftar pelayanan, dan melihat warta transparansi keuangan dari ponsel.
- **Efisiensi Pengurus Gereja**: Majelis dan sekretariat gereja dapat mengelola data jemaat, mengonfirmasi bukti transfer donasi, menerbitkan warta minggu, serta merespon permohonan doa melalui portal admin web.
- **Keamanan & Skalabilitas**: Menggunakan autentikasi berbasis Laravel Sanctum & Firebase Auth, Spatie RBAC untuk manajemen hak akses, dan struktur Clean Architecture pada aplikasi mobile.

---

## 🛠 Tech Stack

### Backend & Web Admin
- **Framework**: [Laravel 13.x](https://laravel.com)
- **Runtime Environment**: [PHP 8.4+](https://www.php.net)
- **Web Admin Panel**: [Filament v5.7](https://filamentphp.com)
- **Database**: MySQL 8.0+
- **Authentication**: Laravel Sanctum v4.3 & Firebase Auth (`kreait/laravel-firebase` v7.2)
- **Authorization / RBAC**: Spatie Laravel Permission v8.3
- **Code Quality**: Laravel Pint v1.27, Larastan v3.10, PHPUnit v12.5

### Mobile Application
- **Framework**: [Flutter 3.22+](https://flutter.dev) / [Dart 3.4+](https://dart.dev)
- **State Management**: [Riverpod v2.5.1](https://riverpod.dev) (`flutter_riverpod`, `riverpod_generator`)
- **Networking**: [Dio v5.4.3](https://pub.dev/packages/dio) with `pretty_dio_logger`
- **Routing**: [GoRouter v14.2.0](https://pub.dev/packages/go_router)
- **Functional Error Handling**: [fpdart v1.1.0](https://pub.dev/packages/fpdart) (`Either<Failure, T>`)
- **Code Generation**: Freezed v2.5.5, JsonSerializable v6.8.0
- **Push Notifications**: Firebase Cloud Messaging (`firebase_messaging` v15.2.10)

---

## 📁 Arsitektur & Structure Project

Project ini disusun dalam bentuk monorepo terstruktur yang memisahkan kode Backend API, Aplikasi Mobile, dan Dokumentasi Teknis:

```
church-management-system/
├── backend/                     # Laravel 13 API & Filament v5 Admin Web
│   ├── app/
│   │   ├── Enums/               # Enum domain (ApplicationStatus, PrayerStatus, dll)
│   │   ├── Filament/            # Resources & Pages Portal Web Admin (18 Resources)
│   │   ├── Http/
│   │   │   ├── Controllers/Api/V1/ # REST API Controllers (38 endpoints)
│   │   │   └── Middleware/      # Custom middleware (Authenticate, Sanitize)
│   │   ├── Models/              # Eloquent Models & Relationship definitions (23 Models)
│   │   ├── Policies/            # Spatie RBAC Authorization Policies
│   │   ├── Providers/           # Service Providers (App, AdminPanelProvider)
│   │   └── Services/            # Business Logic & Integration Services (FCM, Auth)
│   ├── config/                  # Konfigurasi aplikasi, auth, & packages
│   ├── database/                # Database Migrations (28 files), Factories, & Seeders
│   ├── routes/                  # Route definitions (api.php, web.php)
│   └── tests/                   # Automated PHPUnit / Pest Test Suites (87 Tests)
│
├── mobile/                      # Aplikasi Mobile Jemaat (Flutter Clean Architecture)
│   ├── android/                 # Native Android wrapper & build setup
│   ├── ios/                     # Native iOS wrapper & build setup
│   ├── lib/
│   │   ├── app/                 # Root App Widget & GoRouter navigation configuration
│   │   ├── core/                # Infrastructure: Network Dio, Storage, Theme, UseCases
│   │   └── features/            # Feature-first Clean Architecture Modules:
│   │       ├── auth/            # Login, Firebase Auth exchange, Session
│   │       ├── home/            # Dashboard jemaat & quick menu
│   │       ├── schedule/        # Jadwal Ibadah & kalender petugas
│   │       ├── warta/           # Warta gereja digital & viewer PDF
│   │       ├── forms/           # Pengajuan pelayanan & dokumen pendukung
│   │       ├── donations/       # Konfirmasi donasi manual & rekening gereja
│   │       ├── prayer_requests/ # Permohonan doa & catatan pastoral
│   │       ├── hymns/           # Buku nyanyian / lirik lagu ibadah
│   │       ├── finance/         # Laporan transparansi keuangan gereja
│   │       ├── directory/       # Direktori jemaat & pengurus majelis
│   │       ├── media/           # Khotbah PDF & arsip media
│   │       ├── search/          # Pencarian global Lintas Modul
│   │       └── profile/         # Profil pengguna & manajemen akun
│   └── test/                    # Automated Unit & Widget Test Suites (63 Tests)
│
├── docs/                        # Dokumentasi bersama & kontrak API
│   ├── api-contract.md          # Kontrak REST API & JSON Payload Schema
│   ├── database.md              # Diagram skema ERD & spesifikasi tabel
│   └── PRODUCTION_READINESS_AUDIT.md # Hasil audit keamanan & kesiapan rilis
│
├── .github/                     # Workflow CI/CD (Backend & Mobile Workflows)
└── README.md                    # Dokumentasi utama proyek
```

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
| **Media & Buku Lagu** | Pencarian Lirik Lagu Ibadah, Khotbah, & Dokumen PDF | Kelola Master Songbook (Lagu/Lirik) & Arsip Khotbah |
| **Notifikasi FCM** | Receiver Push Notification Pesan Gereja & Update Pengajuan | Kirim Pengumuman Broadcast FCM ke Seluruh Device Jemaat |

---

## ⚡ Prerequisites

Sebelum memulai instalasi, pastikan lingkungan pengembangan Anda telah memenuhi kebutuhan perangkat lunak berikut:

### Perangkat Lunak Utama
- **PHP**: Versi `>= 8.4` (dengan ekstensi `pdo`, `pdo_mysql`, `mbstring`, `openssl`, `curl`, `gd`)
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
Di dalam folder [`backend/`](file:///e:/Nero/church-management-system/backend):
```bash
# Menggunakan command bawaan script dev (menjalankan server, queue worker, & vite secara paralel)
composer run dev

# ATAU menjalankan server HTTP Laravel secara terpisah:
php artisan serve
```
- **Portal Web Admin Filament**: Akses melalui browser di `http://127.0.0.1:8000/admin`
- **REST API Base Endpoint**: `http://127.0.0.1:8000/api/v1`

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

---

## 📄 Lisensi

Project ini dilisensikan di bawah **[MIT License](LICENSE)**. Anda bebas mengunduh, memodifikasi, dan mendistribusikan perangkat lunak meupun petunjuk di atas sesuai dengan ketentuan lisensi.
