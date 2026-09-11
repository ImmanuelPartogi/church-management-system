# ADR 13: Sacrament Approval Workflow & Sectoral RBAC Hierarchy

- **Status**: PROPOSED
- **Date**: 2026-09-11
- **Domain**: Module Sakramen (`forms`), Keanggotaan (`membership`), Komunitas (`community`)
- **Related ADRs**: ADR 1 (Tenant Isolation), ADR 2 (Spatie Teams), ADR 6 (12-Module Flags)

---

## 1. Konteks & Latar Belakang

Sebelum membuka implementasi digitalisasi sakramen (Phase 11: Baptis Kudus, Sidi/Katekisasi, Pernikahan Kudus, Atestasi Jemaat), diperlukan pemetaan tata kelola otorisasi gerejawi (*ecclesiastical governance*). 

Dalam tata kelola gereja sinodal/presbiterial (khususnya HKBP), persetujuan sakramen tidak bersifat seragam:
1. **Sintua Sektor / Wijk**: Pejabat pastoral tingkat basis yang membawahi sektor/lingkungan jemaat tertentu. Bertanggung jawab memverifikasi keaktifan jemaat di lingkungannya (misal: verifikasi bahwa calon penerima baptis/sidi benar-benar warga sektor binaannya).
2. **Pendeta Jemaat / Pendeta Ressort**: Pemimpin liturgi dan penanggung jawab doktrin gerejawi yang memverifikasi kelengkapan dokumen pastoral dan mengesahkan pelayanan sakramen sebelum pendaftaran jadwal ibadah.

### Hasil Audit Kode Eksisting (Per September 2026)
Audit menyeluruh pada kode platform mengungkapkan:
- Role Spatie resmi saat ini: `church_admin`, `bendahara`, `pastor`, `staff`, `member`.
- **Tidak ada role Spatie "sintua" maupun "pendeta_ressort"**.
- Keduanya saat ini murni berupa string enum di `ChurchServantRole` (`pdt_resort`, `sintua`, `majelis`, `sector_leader`, `fellowship_leader`) pada model direktori informasional `ChurchServant`. Model ini belum memiliki keterikatan autentikasi atau wewenang otorisasi (*unauthorized directory entity*).

---

## 2. Pilihan Desain Otorisasi

### Opsi 1: Role Spatie Datar (Flat Roles)
Menambahkan role `sintua` dan `pendeta_ressort` langsung ke tabel `roles` Spatie dengan scoping `team_id = church_id`.
- **Kelebihan**: Sederhana diimplementasikan di seeder Spatie.
- **Kelemahan Fatal**: Spatie Teams hanya mempartisi sampai tingkat `church_id`. Akibatnya, Sintua dari **Sektor 1** secara teknis akan memiliki izin Filament untuk menyetujui formulir sakramen milik jemaat di **Sektor 5**, karena keduanya berada di bawah role `sintua` pada `church_id` yang sama. Ini melanggar batas pastoral gereja lokal.

### Opsi 2: Row-Level Sector-Bound Approval Chain (Rekomendasi)
Memisahkan otorisasi menjadi dua lapis:
1. **Lapis Peran Fungsional (Spatie Level)**:
   - Menambahkan permission: `submit form applications`, `verify sectoral form applications`, `approve pastoral form applications`.
   - Role `sintua` memegang permission `verify sectoral form applications`.
   - Role `pastor` memegang permission `approve pastoral form applications`.
2. **Lapis Relasi Data (Policy / Scope Level)**:
   - Sintua ditautkan ke satu atau lebih sektor melalui tabel pivot `church_servant_sectors` atau relasi `ChurchServant::where('member_id', auth()->user()->member->id)`.
   - `ServiceFormApplicationPolicy::verify()` memvalidasi:
     ```php
     return $user->hasRole('sintua')
         && $user->servantProfile?->sector_id === $application->applicantMember->sector_id;
     ```
   - Dengan ini, Sintua Sektor A **hanya dapat melihat dan memverifikasi** permohonan sakramen dari jemaat yang berdomisili di Sektor A.

---

## 3. Alur Kerja Persetujuan Berjenjang (*Approval Workflow Lifecycle*)

Status permohonan sakramen pada tabel `service_form_applications`:
1. `draft`: Disusun oleh jemaat via mobile.
2. `submitted`: Jemaat mengirimkan formulir beserta dokumen persyaratan (akta kelahiran, surat pengantar).
3. `sector_verified`: Sintua Sektor memverifikasi keabsahan data domisili dan pastoral lingkungan jemaat.
4. `pastor_approved`: Pendeta Ressort menyetujui secara doktrinal dan menetapkan jadwal sakramen pada `WorshipSchedule`.
5. `completed`: Sakramen telah dilayankan; sistem otomatis memperbarui profil keanggotaan jemaat (misal: kolom `baptism_date` terisi, atau status sidi naik menjadi anggota penuh berhak perjamuan kudus).
6. `rejected`: Ditolak pada tahap verifikasi sektor atau pastoral dengan `rejection_reason` wajib.

---

## 4. Konsekuensi & Rekomendasi untuk Phase 11
1. Tidak ada kode atau migrasi workflow sakramen yang dibangun sebelum ADR ini disetujui.
2. Phase 11 wajib diawali dengan migrasi relasi user -> `church_servants` dan penegakan policy berbasis sektor sebelum antarmuka form sakramen dibangun.
