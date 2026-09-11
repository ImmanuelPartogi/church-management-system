# Architecture Decision Records (ADR) Catalog

Dokumen ini memuat ringkasan keputusan arsitektural (ADR 1 hingga ADR 11) yang mendasari transformasi Church Management System menjadi platform multi-tenant tingkat lanjut.

---

## Daftar Keputusan Arsitektural

| ADR | Domain / Fitur | Status | Phase Terkait |
| :--- | :--- | :--- | :--- |
| **ADR 1** | Strict Tenant Isolation via Eloquent Global Scope | ACCEPTED | Phase 1E & 3 |
| **ADR 2** | Spatie Permission Teams Migration | ACCEPTED | Phase 2 |
| **ADR 3** | Single Source of Truth Context Middleware (`ResolveChurchContext`) | ACCEPTED | Phase 3 |
| **ADR 4** | Super Admin Cross-Tenant Management & Public API | ACCEPTED | Phase 4A |
| **ADR 5** | Filament Topbar Tenant Switcher via Session Binding | ACCEPTED | Phase 4A |
| **ADR 6** | 12-Module Feature Flag & Authorization Architecture | ACCEPTED | Phase 4B |
| **ADR 7** | Mobile Client Multi-Tenant Integration & Anti-Spoofing Interceptor | ACCEPTED | Phase 4C & 5 |
| **ADR 8** | Tenant-Aware Asynchronous Scoping (`TenantAwareJob`) & Media Partitioning | ACCEPTED | Phase 5 |
| **ADR 9** | Cross-Tenant Reporting, Synod Aggregation & Atomic Cache Locks | ACCEPTED | Phase 6A |
| **ADR 10** | Self-Service Church Registration & HMAC Signed Route Onboarding Pipeline | ACCEPTED | Phase 7 |
| **ADR 11** | In-Memory Synod Report Export Pipeline with Zero Disk Footprint | ACCEPTED | Phase 8 |
| **ADR 12** | Dynamic Mobile Theming per Church & 3-Tier Fallback | ACCEPTED | Phase 9 |

---

## Ringkasan Detail Setiap ADR

### ADR 1: Strict Tenant Isolation via Eloquent Global Scope
- **Konteks**: Seluruh model domain (16 model) harus terisolasi per-gereja tanpa kemungkinan kebocoran data (*cross-tenant leakage*).
- **Keputusan**:
  - Model mengimplementasikan trait `BelongsToChurch` dan global scope `ChurchScope`.
  - Kolom `church_id` tidak pernah dijadikan fillable (`guarded = ['id']`, `church_id` diisi secara otomatis oleh framework dari context aktif).
  - Pengecualian cross-tenant hanya diizinkan secara eksplisit melalui macro `Model::withoutChurch()`.
  - Jika query dieksekusi tanpa konteks tenant aktif pada endpoint yang membutuhkan tenant, sistem melempar `\RuntimeException` fail-loud (bukan `whereRaw('1=0')` yang membingungkan).

### ADR 2: Spatie Permission Teams Migration
- **Konteks**: Pengguna yang sama dapat memiliki peran berbeda di gereja berbeda (misal: Majelis di Gereja A, jemaat biasa di Gereja B).
- **Keputusan**:
  - Mengaktifkan fitur Spatie Teams (`teams => true` di `config/permission.php`).
  - Kolom `team_id` pada tabel `model_has_roles` dan `model_has_permissions` memetakan langsung ke `church_id`.
  - Konteks Spatie di-bind secara otomatis pada lifecycle request melalui `setPermissionsTeamId(app('current_church_id'))`.

### ADR 3: Single Source of Truth Context Middleware (`ResolveChurchContext`)
- **Konteks**: Penentuan tenant aktif harus deterministik, konsisten, dan tahan manipulasi (*anti-spoofing*).
- **Keputusan**:
  - Middleware tunggal `ResolveChurchContext` memproses header `X-Church-Id` atau `X-Church-Slug` (pada API) atau `active_church_id` pada session (pada Web Admin).
  - Melakukan validasi silang zero-trust: jika pengguna terautentikasi mengirim header gereja di mana ia tidak memiliki keanggotaan aktif (`ChurchUserMembership`), sistem melempar `403 TENANT_MEMBERSHIP_MISMATCH`.
  - Membersihkan session usang jika gereja target berstatus `suspended`.

### ADR 4: Super Admin Cross-Tenant Management & Public API
- **Konteks**: Super Admin membutuhkan kemampuan mengelola entitas `Church` secara global, dan aplikasi mobile membutuhkan daftar gereja aktif untuk onboarding/registrasi jemaat.
- **Keputusan**:
  - Endpoint `GET /api/v1/churches` dibuka secara publik (`withoutMiddleware(ResolveChurchContext::class)`) dan hanya mengembalikan gereja dengan status `active`.
  - `ChurchPolicy` mengunci seluruh operasi mutasi hanya untuk `is_super_admin === true`.
  - Record `Church` tidak pernah boleh di-hard-delete (`delete()` selalu return `false`). Manajemen siklus hidup murni melalui status `active` vs `suspended`.

### ADR 5: Filament Topbar Tenant Switcher
- **Konteks**: Super Admin perlu memeriksa dashboard dari sudut pandang gereja tertentu tanpa login ulang.
- **Keputusan**:
  - Komponen Livewire `TenantSwitcher` disematkan pada topbar Filament (`GLOBAL_SEARCH_BEFORE`).
  - Menyimpan pilihan ke session `active_church_id` yang dibaca oleh `ResolveChurchContext`.

### ADR 6: 12-Module Feature Flag & Authorization Architecture
- **Konteks**: Setiap gereja memiliki variasi kebutuhan operasional (misal: beberapa gereja menonaktifkan modul keuangan atau donasi online).
- **Keputusan**:
  - Taksonomi 12 modul didefinisikan secara resmi di tabel `modules` dan di-pivot di `church_modules`.
  - Modul `membership` dan `announcements` ditetapkan sebagai `is_core = true` dan tidak dapat dinonaktifkan.
  - Penegakan otorisasi di level API melalui middleware `module:{key}` yang mengembalikan error terstruktur `403 MODULE_DISABLED`.
  - Penegakan di level Web Admin Filament melalui trait `HasModuleAccess` pada seluruh 19 Filament Resources.

### ADR 7: Mobile Client Multi-Tenant Integration & Anti-Spoofing Interceptor
- **Konteks**: Aplikasi Flutter harus mengalirkan konteks tenant aktif pada setiap request Dio dan menangani perpindahan gereja secara anggun.
- **Keputusan**:
  - `TenantInterceptor` menyuntikkan header `X-Church-Id` dan `X-Church-Slug` secara otomatis.
  - Jika server merespons `403 TENANT_MEMBERSHIP_MISMATCH`, interceptor memicu rekonsiliasi state via `TenantNotifier.reconcileWithUser()` dan melakukan retry otomatis 1x (dengan proteksi guard anti-loop).
  - Penyajian modal bottom sheet pemilihan keanggotaan ganda dikelola di root shell aplikasi via `RootTenantPromptListener`.

### ADR 8: Tenant-Aware Asynchronous Scoping (`TenantAwareJob`) & Media Partitioning
- **Konteks**: Background queue worker berisiko mengalami kebocoran konteks antar-job jika worker memproses job dari tenant berbeda secara berturut-turut.
- **Keputusan Final**:
  - **Two-Tier Dispatcher Guard (`ScopeJobToTenant`)**:
    - Seluruh job domain wajib mengimplementasikan interface `TenantAwareJob` yang membawa `public int $churchId`. Job yang tidak mengimplementasikan interface ini ditolak seketika dengan `UnscopedJobException`.
    - Job lintas-tenant wajib mengimplementasikan `CrossTenantJob` dan dilindungi otorisasi dispatcher: hanya dapat dipicu oleh proses CLI/Scheduler atau Super Admin terverifikasi (`$dispatchedByUserId`). Dispatcher tidak sah ditolak dengan `UnauthorizedCrossTenantDispatchException`.
  - **Context Lifecycle**: Listener event `JobProcessing` mengikat konteks tenant (`current_church_id`, `current_church`, Spatie team). Listener `JobProcessed` dan `JobFailed` mereset seluruh konteks container dan cache Spatie ke kondisi `null` (zero-leak guarantee).
  - **Partisi Media Disk**: Media & berkas disk diisolasi ke direktori berpartisi: `tenants/{church_id}/{feature}/...` via `TenantStorage`.

### ADR 9: Cross-Tenant Reporting & Synod Aggregation Architecture
- **Konteks**: Pimpinan Sinode HKBP membutuhkan visibilitas agregat seluruh gereja tanpa memicu kalkulasi berat di request HTTP utama.
- **Keputusan Final**:
  - Agregasi dilakukan secara asinkron via `GenerateSynodReportSnapshotJob` (mengimplementasikan `CrossTenantJob` dan `ShouldBeUnique`).
  - Menggunakan atomic cache locks pada tabel `cache_locks` dengan override eksplisit `uniqueVia()` pada koneksi database.
  - Menghitung metrik secara simetris antara gereja aktif dan gereja ditangguhkan (`active` vs `suspended`).
  - Menyimpan snapshot historis deterministik di tabel `synod_report_snapshots`.

### ADR 10: Self-Service Church Registration & HMAC Signed Route Onboarding Pipeline
- **Konteks**: Membuka pendaftaran gereja mandiri secara publik tanpa risiko *tenant squatting* atau *premature provisioning*.
- **Keputusan Final**:
  - **Pemisahan Tabel Isolasi**: Pendaftaran ditampung di tabel terpisah `church_registrations` (data pendaftar tidak masuk ke tabel `churches` sampai disetujui).
  - **Mekanisme Verifikasi Tunggal**: Kolom redundan `verification_token` dihapus dari skema; verifikasi email murni stateless menggunakan HMAC signed URL (`URL::temporarySignedRoute`, masa berlaku 24 jam).
  - **Penanganan Race Condition Slug**: Tabrakan slug simultan ditangkap di level database unique constraint dan dikonversi menjadi HTTP 422 JSON yang ramah tanpa crash 500.
  - **Deteksi User Eksisting**: Pengguna terdaftar dideteksi di titik submit form (`existing_user_id`) dan ditampilkan via visual badge di antarmuka Filament.
  - **Persetujuan Atomik**: Persetujuan oleh Super Admin (`ChurchRegistrationResource::approve`) secara atomik dalam satu DB transaction membuat `Church`, mengalokasikan peran `church_admin` dengan Spatie `team_id`, dan mengaktifkan 12 modul secara default.
  - **Scheduled Hard-Pruning**: Perintah terjadwal `php artisan church-registrations:prune-stale --days=7` melakukan hard-delete pada pendaftaran tak terverifikasi >7 hari agar slug segera kembali ke pool publik.

### ADR 11: In-Memory Synod Report Export Pipeline with Zero Disk Footprint
- **Konteks**: Ekspor laporan tahunan sinode (PDF resmi dan spreadsheet CSV) tanpa meninggalkan berkas sampah di server (*zero disk footprint*) dan terlindungi dari kehabisan memori.
- **Keputusan**:
  - PDF dirender menggunakan `barryvdh/laravel-dompdf` langsung di dalam RAM via `$pdf->output()` dan di-stream via `response()->streamDownload()`.
  - CSV dibuat di in-memory buffer `php://temp` dengan UTF-8 BOM (`\xEF\xBB\xBF`) untuk kompatibilitas langsung di Microsoft Excel.
  - Pengaman memori dinamis: `$originalMemoryLimit` dibaca dan dikonversi via `parseIniSize()`; elevasi ke 256M hanya jika diperlukan dan dipulihkan kembali pada blok `finally` (anti-leak worker context).
  - Audit log permanen `SynodDashboard.exported` mencatat otorisasi dan inisiasi penarikan data finansial sinode oleh Super Admin.

### ADR 12: Dynamic Mobile Theming per Church & 3-Tier Fallback
- **Konteks**: Setiap tenant gereja memiliki identitas visual sendiri (warna primer, warna sekunder, versi tema, logo resmi) yang harus dapat dikonfigurasi oleh `church_admin` dan `super_admin`, dipublikasikan secara aman, dan dirender dinamis di aplikasi mobile Flutter.
- **Keputusan**:
  - **Zero-Backfill Migration**: Kolom `theme_primary_color` (`#1B4B66`), `theme_secondary_color` (`#F5A623`), dan `theme_version` (1) ditambahkan ke tabel `churches` dengan default skema database, tanpa kebutuhan script backfill data legacy.
  - **Auto-Increment Cache Invalidation**: Model event `updating` otomatis menaikkan `theme_version` hanya ketika kolom tema mengalami perubahan (`isDirty()`).
  - **Otorisasi Granular & Isolasi Sesi**: `ChurchPolicy::update` tetap terkunci khusus Super Admin. Method `updateTheme` mengizinkan `church_admin` mengubah tema gereja aktifnya murni berdasarkan `app('current_church_id')` (tanpa ketergantungan pada sesi) dan verifikasi status membership aktif di database.
  - **Deterministic Mount (Opsi a)**: Halaman `ManageChurchTheme` menggunakan route statis `/church-theme` tanpa parameter dinamis, mengevaluasi `Gate::authorize('updateTheme', $church)` saat `mount()` dan `save()`, serta menerapkan zero-trust filtering agar kolom sensitif (`slug`, `status`) tidak dapat diutak-atik.
  - **Asymmetric Security Design (Fail-Open)**: Pewarnaan visual menerapkan prinsip *fail-open*; kesalahan storage lokal, kegagalan network, atau format hex tidak valid otomatis jatuh ke warna platform tanpa pernah melempar unhandled exception atau mengunci aplikasi.
  - **3-Tier Mobile Fallback**: Aplikasi Flutter mengimplementasikan Riverpod `ThemeNotifier` dengan urutan: Tier 1 (Cache Lokal `SecureStorageService`) -> Tier 2 (Payload API dengan invalidasi `theme_version`) -> Tier 3 (Default Platform `#1B4B66` dan `#F5A623`).
  - **Preservasi Identitas Lintas Logout (ADR 7.3)**: `ThemeNotifier` hanya mendengarkan `tenantProvider`. Pembersihan token saat logout tidak menghapus active church ataupun tema aktif, memastikan pengalaman *guest browsing* tetap konsisten.

