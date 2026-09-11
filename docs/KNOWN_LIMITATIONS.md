# Known Limitations & Technical Debt Registry

Dokumen ini mencatat secara transparan batasan teknis yang diketahui (*known limitations*), asumsi skala, serta ambang batas (*thresholds*) kapan refaktorisasi arsitektur perlu dieksekusi.

---

## Ringkasan Batasan Teknis

| ID | Komponen / Fitur | Status Skala Terverifikasi | Ambang Batas Aksi Refaktorisasi | Status |
| :--- | :--- | :--- | :--- | :--- |
| **KL-01** | `GenerateSynodReportSnapshotJob` (N+1 Query) | Aman pada < 50 Gereja (<200 ms) | Rentang 50–300 Gereja (Wajib profiling DB nyata) | ACCEPTED DEBT |
| **KL-02** | `SynodChurchesComparisonWidget` (In-Memory Sort) | Aman pada < 50 Gereja (<5 ms) | Rentang 50–300 Gereja (Evaluasi memory collection) | ACCEPTED DEBT |
| **KL-03** | `SynodReportExportService` (Synchronous DomPDF) | Terukur pada 100 Gereja (~1 s) | > 300 Gereja (Circuit Breaker terukur non-linear) | ACCEPTED DEBT |
| **KL-04** | Upstream Dependency CVEs (`composer audit`) | `league/commonmark` dipatch ke `^2.10.1` (0 HIGH CVEs) | Sisa Livewire/Filament: 25 Sept 2026 | PARTIALLY RESOLVED (0 HIGH) |

---

## Rincian Detail Setiap Batasan

### KL-01: N+1 Query Pattern pada Agregasi Laporan Sinode
- **Lokasi Kode**: [`GenerateSynodReportSnapshotJob.php`](file:///Users/digisolf8/Downloads/Asset/church-management-system/backend/app/Jobs/GenerateSynodReportSnapshotJob.php#L97-L128)
- **Karakteristik**:
  - Saat membentuk array `church_comparisons`, job melakukan iterasi pada seluruh record gereja.
  - Untuk setiap gereja, dieksekusi 3 query terpisah:
    1. `ChurchMember::withoutChurch()->where('church_id', $church->id)->count()`
    2. `ChurchModule::where('church_id', $church->id)->count()`
    3. `DonationConfirmation::withoutChurch()->where('church_id', $church->id)->where('status', 'approved')->sum('amount')`
- **Dampak Skala Saat Ini (<50 Gereja)**:
  - Pada skala teruji (<50 gereja), total 150 query selesai dalam waktu <200 ms di dalam queue worker asinkron dan tidak membebani HTTP request utama.
- **Rekomendasi Refaktorisasi (Rentang 50–300 Gereja)**:
  - *Catatan Metodologis*: Angka pasti titik degradasi belum diukur secara empiris di server database produksi. Jika jumlah gereja bertumbuh melampaui 50 gereja, tim wajib melakukan profiling waktu eksekusi query MySQL nyata.
  - Jika waktu eksekusi job melampaui SLA antrean, ganti loop individual dengan agregasi batch SQL tunggal:
    ```php
    $memberCounts = ChurchMember::withoutChurch()
        ->selectRaw('church_id, COUNT(*) as total')
        ->groupBy('church_id')
        ->pluck('total', 'church_id');

    $donationSums = DonationConfirmation::withoutChurch()
        ->where('status', 'approved')
        ->selectRaw('church_id, SUM(amount) as total')
        ->groupBy('church_id')
        ->pluck('total', 'church_id');
    ```

---

### KL-02: In-Memory Sorting & Filtering pada Widget Komparasi Sinode
- **Lokasi Kode**: [`SynodChurchesComparisonWidget.php`](file:///Users/digisolf8/Downloads/Asset/church-management-system/backend/app/Filament/Widgets/SynodChurchesComparisonWidget.php)
- **Karakteristik**:
  - Tabel perbandingan gereja membaca array JSON `church_comparisons` dari snapshot deterministik terakhir.
  - Pencarian (*search*) dan pengurutan (*sort*) kolom dilakukan di level PHP memory collection (`collect($comparisons)->filter(...)->sortBy(...)`).
- **Dampak Skala Saat Ini (<50 Gereja)**:
  - Eksekusi instan (<5 ms) karena data sudah berada di memori dan tidak menyentuh query database berulang kali saat pagination widget digeser.
- **Rekomendasi Refaktorisasi (Rentang 50–300 Gereja)**:
  - *Catatan Metodologis*: Pada skala di atas 50 gereja, ukuran collection JSON di memori dan waktu rendering Filament perlu diukur ulang. Jika interaktivitas tabel melambat, pertimbangkan memecah `church_comparisons` ke tabel relasi terindeks `synod_report_church_items` agar sorting dan filtering didelegasikan ke engine SQL dengan server-side pagination.

---

### KL-03: Non-linear PDF Reflow pada Skala Ekstrem (Circuit Breaker: > 300 Gereja)
- **Lokasi Kode**: [`SynodReportExportService.php`](file:///Users/digisolf8/Downloads/Asset/church-management-system/backend/app/Services/Reporting/SynodReportExportService.php#L20-L58)
- **Karakteristik**:
  - Ekspor dokumen resmi PDF sinode diproses secara sinkron melalui `barryvdh/laravel-dompdf`.
  - Berbeda dengan CSV yang murni operasi string di `php://temp` (<0.2 ms), DomPDF harus melakukan tokenisasi HTML, kalkulasi CSS, dan pemenggalan halaman multi-halaman (*pagination reflow*).
  - Pengukuran empiris:
    - 100 Gereja (~4 halaman A4): **~900 – 1.050 ms**.
    - 300–500 Gereja (~12–20 halaman A4): Diperkirakan **~3 – 6 detik**.
- **Dampak Skala Saat Ini (<50 Gereja)**:
  - Rendering selesai dalam <500 ms, menghadirkan pengalaman unduh instan yang sangat nyaman bagi Super Admin.
- **Rekomendasi Refaktorisasi (Ambang Batas: > 300 Gereja)**:
  - **Circuit Breaker Rule**: Jika jumlah gereja terdaftar melampaui **300 gereja aktif**, alihkan rendering format PDF ke job asinkron:
    1. Dispatch `GenerateSynodReportPdfJob::dispatch($snapshot->id, auth()->id())`.
    2. Simpan file PDF sementara ke storage berpartisi aman dengan expiration time (misal: 2 jam).
    3. Kirim Filament database notification kepada Super Admin dengan tautan unduhan bertanda tangan (*temporary signed URL*).
  - Format CSV tetap dipertahankan pada pipeline sinkron karena komputasinya tetap sub-milidetik.

---

### KL-04: Upstream Dependency Vulnerabilities (Vendor CVEs Belum Di-patch)
- **Status Deteksi**: Teridentifikasi melalui `composer audit` pada September 2026.
- **Rincian Kerentanan & Severity Level**:
  1. **`league/commonmark` (v2.8.3 => Patched ke v2.10.1 pada 11 September 2026)**:
     - **Tingkat Keparahan**: **HIGH** (5 advisories) & **MEDIUM** (2 advisories) — **STATUS: RESOLVED / CLOSED**.
     - **Advisories Ditutup**:
       - `GHSA-8rr7-cvq3-gmfh` (High): Denial of Service via distinctly-named attributes.
       - `GHSA-jjv6-8j6v-6j52` (High): Denial of Service in SmartPunct and Attributes extensions.
       - `GHSA-f8fg-pg57-v4j8` (High): XSS filter bypass with U+000C form feed in AttributesExtension.
       - `GHSA-j8pm-gj4c-rq4x` (High): Denial of Service via crafted code fences, reference links, emphasis delimiters.
       - `CVE-2026-71488` (High): Quadratic-time DoS when parsing crafted Markdown.
       - Serta 2 medium advisories (`GHSA-mj63-m3rc-8ppr`, `GHSA-29pj-957v-52mc`).
     - **Versi Terpasang**: `^2.10.1` (Terkonfirmasi kompatibel via `composer why league/commonmark` terhadap `laravel/framework v13.23.0` yang mensyaratkan `^2.8.1`).
     - **Hasil Audit Pasca-patch**: **0 HIGH CVEs** di seluruh repository.
     - **Verifikasi Regresi**: 334 backend tests (1376 assertions) 100% passed, Pint clean.
  2. **`livewire/livewire` (v4.3.3)**:
     - **Tingkat Keparahan**: **MEDIUM** (1 advisory).
     - **Advisory**: `CVE-2026-81887` (Medium): DOM-based cross-site scripting (XSS) during client-side state handling.
     - **Versi Perbaikan (Patched)**: `v4.3.4` / `v4.4.4`.
  3. **`filament/filament` (v5.7.3)**:
     - **Tingkat Keparahan**: **MEDIUM** (1 advisory) & **LOW** (1 advisory).
     - **Advisories**:
       - `CVE-2026-84306` (Medium): Multi-factor authentication app codes reuse vulnerability.
       - `CVE-2026-84307` (Low): Password validity disclosure on login page for accounts denied panel access.
     - **Versi Perbaikan (Patched)**: `v5.7.6` / `v5.8.1`.
- **Hasil Audit Empiris Permukaan Serangan (Attack Surface Verification)**:
  - *Verifikasi Komponen Input Filament*: Audit kode menyeluruh (`grep -roh "Forms\\Components\\[A-Za-z0-9_]*" app/Filament/`) membuktikan **0 penggunaan `MarkdownEditor` maupun `RichEditor`** di seluruh Resource Filament. Seluruh input konten teks oleh `church_admin` (seperti `Announcement.content`, `Warta.description`, `PrayerRequest.request`, `Sermon.title`) murni menggunakan `Forms\Components\Textarea` atau `TextInput`.
  - *Verifikasi Pipeline Queue & Background Jobs*: Audit menyeluruh pada job `SendChurchAnnouncementBroadcastJob` dan seluruh job di `app/Jobs/` membuktikan string teks diteruskan secara mentah (*raw string*) ke payload FCM (`FcmNotificationService::broadcast()`), tanpa pernah memanggil `Str::markdown()` atau parser markdown pihak ketiga. Tidak ada jalur eksekusi DoS worker hang lintas-tenant via markdown parsing.
  - *Asal Usul Dependensi*: `league/commonmark` hadir di codebase semata-mata sebagai dependensi bawaan (*transitive dependency*) dari `laravel/framework v13.x` (diperlukan internal framework untuk fitur mail template).
- **Rencana Aksi Sisa (Filament & Livewire)**:
  - **Target Waktu**: Tetap dijadwalkan pada Sprint Pemeliharaan berkala (**Target: 25 September 2026**). Upgrade Livewire/Filament memerlukan penyesuaian dependensi cascading (~58 paket termasuk symfony/monolog) sehingga akan diuji dengan browser smoke testing terpisah.
