# ADR 14: Intra-Tenant Member-Level Scoping Architecture

- **Status**: PROPOSED
- **Date**: 2026-09-11
- **Domain**: Keuangan Jemaat (`finance`, `donations`), Profil Anggota (`membership`)
- **Related ADRs**: ADR 1 (Strict Tenant Isolation), ADR 7 (Mobile Multi-Tenant)

---

## 1. Konteks & Masalah

Seluruh arsitektur keamanan yang dibangun dari Phase 1E hingga Phase 9 beroperasi pada batas isolasi tenant tingkat **`church_id`**. Seluruh data di dalam satu tenant dianggap milik bersama di bawah wewenang `church_admin`.

Namun, untuk transparansi dan layanan jemaat personal (Phase 12: Riwayat Persembahan Pribadi, Status Konfirmasi Donasi, Pengajuan Doa Pribadi, dan Dokumen Sakramen Keluarga), sistem memerlukan dimensi isolasi sekunder yang lebih dalam: **Member-Level Scoping di dalam `church_id` yang sama**.

### Risiko yang Harus Dicegah:
1. **Kebocoran Data Finansial Antar-Jemaat**: Jemaat B tidak boleh dapat melihat nominal atau bukti transfer persembahan Jemaat A, meskipun keduanya terdaftar aktif di gereja yang sama (`church_id` identik).
2. **Kebutuhan Akses Administratif**: Bendahara (`bendahara`) dan Admin (`church_admin`) tetap harus dapat melihat seluruh persembahan jemaat di gerejanya secara agregat untuk keperluan rekonsiliasi kas dan pelaporan.

---

## 2. Keputusan Desain: Trait `BelongsToMember` & Dual-Pathway API

### 1. Trait `BelongsToMember`
Model personal (seperti `DonationConfirmation`, `PrayerRequest`, `ServiceFormApplication`) mengimplementasikan [`App\Traits\BelongsToMember`](file:///Users/digisolf8/Downloads/Asset/church-management-system/backend/app/Traits/BelongsToMember.php):
```php
trait BelongsToMember
{
    public function scopeForMember(Builder $query, ?User $user = null): Builder
    {
        $user ??= auth()->user();
        if (! $user) {
            return $query->whereRaw('1 = 0');
        }
        return $query->where($this->getTable().'.user_id', $user->id);
    }

    public function isOwnedBy(User $user): bool
    {
        return (int) $this->user_id === (int) $user->id;
    }
}
```

### 2. Dual-Pathway Separation (Pemisahan Jalur Personal vs Administratif)
- **Jalur Personal (Self-Service)**:
  - Endpoint `GET /api/v1/me/donations` murni menerapkan `DonationConfirmation::forMember($user)`.
  - Endpoint detail `GET /api/v1/donations/{id}` memverifikasi kepemilikan:
    `if ($donation->user_id !== $user->id) abort(403);`
- **Jalur Administratif (Church Staff)**:
  - Dikelola melalui antarmuka Filament atau endpoint khusus pengurus dengan wewenang `manage donations` / role `bendahara`.
  - Jalur ini mengabaikan filter `user_id` tetapi tetap terkunci ketat oleh `ChurchScope` (`church_id` tenant aktif).

---

## 3. Hasil Pembuktian Teknis (*Proof-of-Concept Verification*)

Telah dibuktikan secara empiris melalui test suite [`MemberLevelDonationScopingTest`](file:///Users/digisolf8/Downloads/Asset/church-management-system/backend/tests/Feature/Member/MemberLevelDonationScopingTest.php) (3 passed, 18 assertions):
1. **Personal Listing**: Jemaat A hanya menerima 2 record donasi miliknya sendiri saat mengakses `/api/v1/me/donations`.
2. **Intra-Tenant Protection**: Jemaat B di gereja yang sama ditolak keras dengan HTTP 403 saat mencoba mengakses donasi milik Jemaat A secara langsung.
3. **Administrative Visibility**: Bendahara gereja memegang wewenang penuh atas seluruh 3 donasi jemaat di dalam tenant.

---

## 4. Konsekuensi untuk Phase 12
- Desain ini siap diimplementasikan secara luas pada Phase 12 (Transparansi Keuangan Jemaat).
- Sesuai stop condition: Tidak ada antarmuka UI mobile lengkap yang dibangun pada fase spike ini.
