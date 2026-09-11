# ADR 13: Sacrament Approval Workflow & Sectoral RBAC Hierarchy

- **Status**: ACCEPTED
- **Date**: 2026-09-11
- **Domain**: Modul Sakramen (`forms`), Keanggotaan (`membership`), Komunitas & Pelayan (`community`)
- **Related ADRs**: ADR 1 (Tenant Isolation), ADR 2 (Spatie Teams per Church), ADR 6 (12-Module Flags), ADR 7 (Multi-Membership), ADR 14 (Intra-Tenant Scoping)

---

## 1. Konteks & Latar Belakang

Sebelum membuka implementasi digitalisasi sakramen (Phase 11: Baptis Kudus, Sidi/Katekisasi, Pernikahan Kudus, Atestasi Masuk/Keluar), diperlukan pemetaan tata kelola otorisasi gerejawi (*ecclesiastical governance*).

Dalam tata kelola gereja sinodal/presbiterial (khususnya HKBP):
1. **Sintua Sektor / Wijk**: Pejabat pastoral tingkat basis yang membawahi lingkungan/sektor jemaat. Bertanggung jawab memverifikasi keaktifan jemaat di lingkungannya (misal: verifikasi kebenaran domisili dan status pastoral calon penerima baptis/sidi).
2. **Pendeta Jemaat / Pendeta Ressort**: Pemimpin liturgi dan penanggung jawab doktrin gerejawi tertinggi di ressort yang mengesahkan pelayanan sakramen sebelum pendaftaran jadwal ibadah sakramen.

### Hasil Audit Kode Eksisting (Per September 2026)
- Role Spatie resmi saat ini: `church_admin`, `bendahara`, `pastor`, `staff`, `member`.
- **Tidak ada role Spatie "sintua" maupun "pdt_resort"**. Keduanya saat ini murni berupa string enum di `ChurchServantRole` pada model direktori informasional `ChurchServant`. Model ini belum memiliki keterikatan autentikasi atau wewenang otorisasi (*unauthorized directory entity*).
- Belum ada policy yang membatasi wewenang verifikasi Sintua hanya ke sektor binaannya.

---

## 2. Keputusan Arsitektur Otorisasi

### A. Granularitas Penugasan Sektor Sintua: Many-to-Many Scoped Pivot
Hubungan Sintua dengan Sektor mengadopsi model **Many-to-Many** untuk mengakomodasi realitas lapangan gerejawi (*ad interim*, kekosongan pelayan wijk, atau penggabungan wijk sementara).

**Aturan Isolasi Tenant (Strict Constraint)**:
Pivot table `church_servant_sectors` **wajib memuat kolom `church_id`** (bukan hanya `church_servant_id` dan `sector_id`):
```sql
CREATE TABLE church_servant_sectors (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    church_id BIGINT UNSIGNED NOT NULL,
    church_servant_id BIGINT UNSIGNED NOT NULL,
    sector_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL,
    FOREIGN KEY (church_id) REFERENCES churches(id) ON DELETE CASCADE,
    FOREIGN KEY (church_servant_id) REFERENCES church_servants(id) ON DELETE CASCADE,
    FOREIGN KEY (sector_id) REFERENCES sectors(id) ON DELETE CASCADE,
    UNIQUE KEY uk_servant_sector (church_id, church_servant_id, sector_id)
);
```
**Rasional**: Scoping `church_id` pada tabel pivot mencegah risiko penugasan pelayan ke sektor milik gereja lain akibat kesalahan data entry, menjamin penegakan `ChurchScope` secara simetris di seluruh domain model.

---

### B. Rantai Identitas, Model Event Hooks, & Idempotent Backfill
Autentikasi dan otorisasi login Sintua ditarik secara deterministik melalui rantai:
$$\text{User} \longleftrightarrow \text{ChurchMember} \longleftrightarrow \text{ChurchServant}$$

1. **Role & Permission Spatie**:
   - Role baru: `sintua`.
   - Permission baru: `verify sectoral sacraments`, `approve final sacraments`.
   - Role `sintua` memegang: `verify sectoral sacraments`.
   - Role `pastor` memegang: `verify sectoral sacraments` (sebagai supervisor).
   - Permission `approve final sacraments` dibatasi eksklusif kepada pimpinan jemaat / Pendeta Ressort.

2. **Otomatisasi Penugasan Role via Model Event Hooks (Bukan Asumsi Statis)**:
   Untuk mencegah celah senyap di mana akun jemaat yang menjadi pelayan tidak pernah mendapatkan role Spatie:
   - **`ChurchServantObserver`**:
     - Saat `ChurchServant` dibuat/diupdate dengan `role = 'sintua'` dan `active = true`: Jika relasi `member->user_id` tersedia, otomatis berikan role Spatie `sintua` pada `team_id = church_id`.
     - Saat `ChurchServant` di-nonaktifkan (`active = false`) atau dihapus: otomatis cabut role Spatie `sintua` dari user terkait.
   - **`ChurchMemberObserver`**:
     - Saat `ChurchMember` ditautkan ke `User` baru (baik via klaim self-registration Phase 7 maupun pembuatan user oleh admin): periksa apakah anggota ini memiliki profil `ChurchServant` aktif ber-role `sintua`. Jika ya, langsung tetapkan role Spatie `sintua`.
   - **Idempotent Artisan Command**:
     - Disediakan command `php artisan church:sync-servant-roles` untuk rekonsiliasi data historis/legacy secara batch dan all-or-nothing.

---

### C. Diferensiasi Wewenang Pastoral: Eksklusif `pdt_resort` (*Fail-Closed by Default*)
Menghindari pembagian wewenang yang terlalu longgar ke seluruh user ber-role `pastor`:
- Pengesahan pastoral akhir (*ecclesiastical final approval*) **hanya dapat dilakukan oleh pengguna yang memegang permission `approve final sacraments`**.
- Pada model `ChurchServant`, ditambahkan flag boolean eksplisit `is_lead_pastor` (atau `role = 'pdt_resort'`).
- Hanya satu Pendeta Ressort / Pimpinan Jemaat per gereja yang di-assign permission `approve final sacraments`. Pendeta jemaat bawahan, pendeta diperbantukan, atau vikaris hanya memiliki wewenang verifikasi administrasi/katekisasi, tetapi tidak dapat menerbitkan akta/surat sakramen resmi tanpa persetujuan Pendeta Ressort.

---

### D. Konfigurasi Gereja Tanpa Sektor: Explicit Flag & Fail-Loud Validation
Menolak keras kesimpulan implisit dari ketiadaan data (`sectors()->count() === 0`):
1. **Kolom Eksplisit di Tabel `churches`**:
   - Ditambahkan kolom `requires_sector_verification` (boolean, default: `true`).
   - Super admin atau church admin mengonfigurasi opsi ini secara sadar melalui pengaturan gereja di Filament.
2. **Prinsip Fail-Loud**:
   - **Kasus A: `requires_sector_verification = true`**:
     Jika jemaat mengajukan permohonan sakramen namun data sektor gereja kosong ATAU pemohon belum memiliki `sector_id`, sistem **TIDAK BOLEH** diam-diam melompat ke pendeta atau admin. Permohonan **tertahan dengan pesan validasi eksplisit**:
     > *"Konfigurasi sektor jemaat belum lengkap. Hubungi administrasi gereja untuk penataan wijk/lingkungan sebelum memproses sakramen."*
   - **Kasus B: `requires_sector_verification = false`**:
     Hanya jika flag ini secara sadar di-nonaktifkan oleh admin (misal untuk Pos Pelayanan / Gereja Pagaran kecil tanpa pembagian wijk), alur verifikasi sektor dilewati secara terencana dan permohonan langsung masuk ke antrean verifikasi pastoral.

---

## 3. Alur Kerja Persetujuan Berjenjang (*Sacrament Approval Lifecycle*)

Status pada tabel `service_form_applications`:
1. `draft`: Disusun oleh jemaat melalui aplikasi mobile.
2. `submitted`: Jemaat mengirimkan formulir beserta dokumen persyaratan (akta kelahiran, surat pengantar).
3. `sector_verified`: (Jika `requires_sector_verification = true`) Diverifikasi oleh Sintua Sektor yang penugasan sektornya di `church_servant_sectors` cocok dengan `applicantMember.sector_id`.
4. `pastor_approved`: Disetujui secara doktrinal dan kanonik oleh Pendeta Ressort pemegang `approve final sacraments`. Menetapkan jadwal ibadah pada `WorshipSchedule`.
5. `completed`: Sakramen telah dilayankan; sistem otomatis memperbarui data profil sakramen jemaat di `church_members` (misal: tanggal baptis, tanggal sidi, nomor surat atestasi).
6. `rejected`: Ditolak pada tahap sektor atau pastoral dengan kewajiban mengisi `rejection_reason`.

---

## 4. Rencana Kerja Implementasi (Phase 11)
1. **Migration Layer**:
   - Tambahkan `requires_sector_verification` pada tabel `churches`.
   - Buat tabel pivot terisolasi `church_servant_sectors` (`church_id`, `church_servant_id`, `sector_id`).
   - Tambahkan flag `is_lead_pastor` pada tabel `church_servants`.
   - Tambahkan kolom approval audit trail pada `service_form_applications` (`sector_reviewed_by`, `sector_reviewed_at`, `pastor_reviewed_by`, `pastor_reviewed_at`).
2. **Authorization & Observer Layer**:
   - Daftarkan role Spatie `sintua` dan permission `verify sectoral sacraments` serta `approve final sacraments`.
   - Pasang observer pada `ChurchServant` dan `ChurchMember` untuk auto-sync role.
   - Buat command `church:sync-servant-roles`.
3. **Policy & Workflow Layer**:
   - Bangun `ServiceFormApplicationPolicy` dengan penegakan row-level sector match.
   - Bangun `SacramentWorkflowService` untuk transisi state yang atomik dalam `DB::transaction`.
4. **Mobile & UI Layer**:
   - Formulir pendaftaran sakramen interaktif di Flutter dengan upload dokumen persyaratan.
   - Portal verifikasi sektor Sintua dan pengesahan Pendeta di Filament/Mobile.
