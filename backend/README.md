# Church Management System — Backend

Laravel 12: REST API (dikonsumsi aplikasi `mobile/`) + Web Admin (Filament),
dalam satu aplikasi yang sama. Business logic dipusatkan di Service layer
supaya API dan Filament tidak duplikasi logic.

> Status: **Fase Setup Awal** — struktur folder & konfigurasi dasar sudah
> siap, implementasi modul (Authentication, Jadwal, Warta, Formulir,
> Donasi, Keuangan, dll) menyusul di fase pengembangan berikutnya.

## Arsitektur

```
app/
├── Http/
│   ├── Controllers/Api/V1/   # controller REST API, tipis — panggil Service
│   ├── Requests/Api/V1/      # Form Request (validasi)
│   ├── Resources/Api/V1/     # API Resource (response shape)
│   └── Middleware/
├── Services/                 # business logic — dipakai oleh Controller & Filament
├── Repositories/
│   └── Contracts/              # interface repository
├── DTO/                       # data transfer object antar layer
├── Enums/                      # status formulir/donasi, kategori, dll
├── Policies/                    # otorisasi per role
├── Models/                       # Eloquent model
├── Filament/
│   ├── Resources/                # CRUD Web Admin per modul
│   ├── Pages/
│   ├── Widgets/                   # widget dashboard (grafik keuangan, dll)
│   └── Clusters/
├── Jobs/ Events/ Listeners/ Notifications/
└── Exceptions/
```

### Prinsip

- Flutter **hanya** lewat REST API (`routes/api.php`, prefix `/api/v1`).
- Filament **tidak** memanggil REST API — akses langsung ke Service layer.
- Business logic **hanya** di Service layer; Controller dan Filament Resource
  sama-sama memanggil Service yang sama.
- Role & permission: `spatie/laravel-permission` (Superadmin, Pdt Resort,
  Sekretaris, Bendahara, Pimpinan Majelis).

## Setup Lokal

1. Install PHP ≥ 8.3, Composer, MySQL.
2. Install dependency:
   ```bash
   composer install
   ```
3. Setup environment:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```
4. Sesuaikan kredensial database di `.env`, lalu migrate:
   ```bash
   php artisan migrate
   ```
5. Jalankan server:
   ```bash
   php artisan serve
   ```
6. Web Admin bisa diakses di `http://localhost:8000/admin` (setelah user
   admin pertama dibuat — perintah seeder menyusul di fase Auth & Role
   Management).

### Firebase

Simpan service account JSON di `storage/app/firebase/service-account.json`
(path bisa disesuaikan lewat `FIREBASE_CREDENTIALS` di `.env`). File ini
**tidak** boleh di-commit — sudah masuk `.gitignore`.

## Coding Standard

```bash
composer lint          # Laravel Pint (code style)
composer analyse        # Larastan / PHPStan (static analysis)
composer test            # PHPUnit
```

Jalankan ketiganya sebelum push — CI (`.github/workflows/backend-ci.yml`)
menjalankan hal yang sama di setiap PR.
