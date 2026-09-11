# Production Operations & Deployment Runbook

Panduan operasional resmi untuk deployment, pemeliharaan (*maintenance*), dan troubleshooting Church Management System di lingkungan server produksi.

> [!IMPORTANT]
> **Status Kesiapan Produksi & Prasyarat Pra-Rilis:**
> Seluruh arsitektur multi-tenant, model domain, dan alur pelaporan telah terverifikasi ketat melalui automated regression suite internal (314 backend tests, 84 mobile tests). Namun, dokumen ini **bukan jaminan kelayakan rilis tanpa uji lanjutan**. Sebelum *go-live* skala penuh, tim pengembang dan operator sistem **diwajibkan** menjalankan tahapan verifikasi independen:
> 1. **Audit Keamanan Independen & Penetration Testing**: Pengujian penetrasi pihak ketiga untuk membuktikan isolasi data dan keamanan auth.
> 2. **Load & Stress Testing**: Pengujian di bawah trafik konkuren riil multi-user (bukan simulasi single-request sekuensial).
> 3. **Audit & Patching Dependensi**: Resolusi kerentanan pihak ketiga secara berkala via `composer audit`.
> 4. **Uji Failover Nyata**: Verifikasi pemulihan saat koneksi database atau antrean worker mengalami putus-sambung jaringan.

---

## 📋 Daftar Isi
1. [Spesifikasi Server & Prerequisites](#1-spesifikasi-server--prerequisites)
2. [Matriks Konfigurasi Environment (.env)](#2-matriks-konfigurasi-environment-env)
3. [Langkah Deployment Pertama Kali (Initial Setup)](#3-langkah-deployment-pertama-kali-initial-setup)
4. [Supervisor Queue Worker Daemon](#4-supervisor-queue-worker-daemon)
5. [Laravel Scheduler & OS Crontab](#5-laravel-scheduler--os-crontab)
6. [Storage Permissions & Symlinks](#6-storage-permissions--symlinks)
7. [Prosedur Deployment Rutin (Zero-Downtime Pipeline)](#7-prosedur-deployment-rutin-zero-downtime-pipeline)
8. [Troubleshooting & Runbook Tanggap Darurat](#8-troubleshooting--runbook-tanggap-darurat)

---

## 1. Spesifikasi Server & Prerequisites

### Rekomendasi Hardware Minimal:
- **CPU**: 2 vCPU
- **RAM**: Minimal 2 GB (Disarankan 4 GB untuk menampung rendering PDF multi-halaman dan antrean background worker secara bersamaan)
- **Disk**: 20 GB SSD

### Software Stack:
- **Operating System**: Ubuntu 22.04 LTS / 24.04 LTS atau Debian 12
- **PHP**: Versi `8.4` (CLI & FPM) dengan ekstensi:
  `php8.4-fpm`, `php8.4-cli`, `php8.4-mysql`, `php8.4-mbstring`, `php8.4-xml`, `php8.4-curl`, `php8.4-gd`, `php8.4-zip`, `php8.4-bcmath`, `php8.4-intl`
- **Database Server**: MySQL `8.0+` atau MariaDB `10.6+`
- **Web Server**: Nginx (direkomendasikan) atau Apache 2.4
- **Process Manager**: Supervisor
- **Node.js**: Versi `20.x` LTS (untuk build asset Filament)

---

## 2. Matriks Konfigurasi Environment (.env)

Pastikan variabel-variabel kunci berikut terkonfigurasi dengan benar pada file `.env` produksi:

```ini
APP_NAME="Church Management System"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://cms.sinode-hkbp.org

# Database Configuration
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=church_management_prod
DB_USERNAME=cms_user
DB_PASSWORD="STRONG_PRODUCTION_PASSWORD"

# Cache & Queue Drivers (Wajib Menggunakan Database / Redis untuk Dukungan Atomic Locks)
CACHE_STORE=database
QUEUE_CONNECTION=database
SESSION_DRIVER=database

# Mail Configuration (Untuk Verifikasi Email Pendaftaran Gereja Mandiri)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailgun.org
MAIL_PORT=587
MAIL_USERNAME=postmaster@sinode-hkbp.org
MAIL_PASSWORD="SECRET_SMTP_PASSWORD"
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="no-reply@sinode-hkbp.org"
MAIL_FROM_NAME="Kantor Pusat Sinode HKBP"

# Firebase Cloud Messaging & Service Account (Untuk Broadcast Mobile)
FIREBASE_CREDENTIALS=/var/www/church-management-system/backend/storage/app/firebase/service-account.json
```

---

## 3. Langkah Deployment Pertama Kali (Initial Setup)

```bash
# 1. Masuk ke direktori web root
cd /var/www/church-management-system/backend

# 2. Install dependensi PHP tanpa paket dev
composer install --no-dev --optimize-autoloader

# 3. Generate APP_KEY
php artisan key:generate --force

# 4. Jalankan Migrasi Database & Seeder Awal
php artisan migrate --force
php artisan db:seed --class=RolesAndPermissionsSeeder --force
php artisan db:seed --class=ModuleSeeder --force

# 5. Jalankan Backfill Modul Default (Memastikan seluruh gereja terprovisioning 12 modul)
php artisan churches:backfill-modules

# 6. Buat Symlink Storage Publik
php artisan storage:link

# 7. Compile Asset Web Admin Filament
npm ci
npm run build

# 8. Optimasi Caching Framework
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
```

---

## 4. Supervisor Queue Worker Daemon

Background queue worker mutlak diperlukan untuk:
1. Pengiriman notifikasi broadcast FCM (`SendChurchAnnouncementBroadcastJob`).
2. Kalkulasi agregat laporan sinode (`GenerateSynodReportSnapshotJob`).

### Konfigurasi Supervisor
Buat file `/etc/supervisor/conf.d/church-cms-worker.conf`:

```ini
[program:church-cms-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/church-management-system/backend/artisan queue:work database --sleep=3 --tries=3 --backoff=15,60,300 --max-time=3600 --memory=256
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

### Mengaktifkan Worker
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start church-cms-worker:*
```

---

## 5. Laravel Scheduler & OS Crontab

Platform mengandalkan Laravel Scheduler untuk dua tugas kritis yang didefinisikan di `routes/console.php`:
1. `synod:generate-report`: Pembuatan snapshot laporan konsolidasi sinode harian (Pukul 00:05).
2. `church-registrations:prune-stale --days=7`: Pembersihan berkala pendaftaran yang belum diverifikasi selama >7 hari (Pukul 02:00) agar slug kembali tersedia.

### Konfigurasi Crontab Server
Jalankan `sudo crontab -e -u www-data` dan tambahkan satu baris berikut:

```cron
* * * * * cd /var/www/church-management-system/backend && php artisan schedule:run >> /dev/null 2>&1
```

### Verifikasi Jadwal Aktif
```bash
cd /var/www/church-management-system/backend
php artisan schedule:list
```

---

## 6. Storage Permissions & Symlinks

Pastikan user web server (`www-data`) memiliki hak akses baca-tulis penuh pada direktori berikut:

```bash
cd /var/www/church-management-system/backend

sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Verifikasi symlink storage
php artisan storage:link
```

---

## 7. Prosedur Deployment Rutin (Zero-Downtime Pipeline)

Saat melakukan rilis versi baru (*git pull* dari branch `main`), jalankan urutan perintah berikut:

```bash
cd /var/www/church-management-system/backend

# 1. Aktifkan Maintenance Mode
php artisan down --render="errors::503" --secret="BYPASS_SECRET_TOKEN"

# 2. Tarik kode terbaru
git pull origin main

# 3. Update dependensi jika ada perubahan
composer install --no-dev --optimize-autoloader

# 4. Jalankan migrasi database
php artisan migrate --force

# 5. Bersihkan dan segarkan cache
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# 6. Restart Queue Worker (Wajib agar worker memuat kode baru di memory)
php artisan queue:restart
sudo supervisorctl restart church-cms-worker:*

# 7. Nonaktifkan Maintenance Mode
php artisan up
```

---

## 8. Troubleshooting & Runbook Tanggap Darurat

### Problem 1: Worker Tidak Memproses Job Latar Belakang
```bash
# Periksa ukuran antrean:
php artisan queue:monitor default

# Periksa status supervisor daemon:
sudo supervisorctl status church-cms-worker:*

# Periksa log antrean:
tail -n 100 /var/log/supervisor/church-cms-worker.log
```

### Problem 2: Penanganan Failed Jobs (Antrean Gagal)
```bash
# Melihat daftar seluruh job yang gagal permanen:
php artisan queue:failed

# Mencoba ulang satu job spesifik:
php artisan queue:retry <JOB_ID>

# Mencoba ulang seluruh job yang gagal:
php artisan queue:retry all

# Menghapus job yang gagal setelah diinvestigasi:
php artisan queue:forget <JOB_ID>
```

### Problem 3: Error 403 Invalid Signature pada Verifikasi Email Pendaftaran
- **Penyebab**: `APP_URL` di `.env` tidak sama persis dengan domain yang diakses oleh pendaftar (misal: `http://` vs `https://` atau perbedaan port).
- **Solusi**: Pastikan `APP_URL` pada `.env` server produksi menggunakan protokol dan domain publik resmi (`https://cms.sinode-hkbp.org`).
