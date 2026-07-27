# API Contract — Church Management System

Dokumen acuan bersama antara `backend/` dan `mobile/` sebelum implementasi
tiap modul dimulai. Isi setiap bagian dengan endpoint, request/response
shape, dan status code sebelum coding fitur terkait dimulai (Tahap 3 pada
tahapan setup proyek).

Base URL: `{APP_URL}/api/v1`
Auth: `Authorization: Bearer <sanctum_token>` (kecuali endpoint auth)

## Format Response Standar

```json
{
  "success": true,
  "message": "string",
  "data": {},
  "errors": null
}
```

## Modul

| Modul | Endpoint prefix | Status |
|---|---|---|
| Auth | `/auth/*` | Belum didefinisikan |
| Beranda | `/home` | Belum didefinisikan |
| Jadwal & Kalender | `/schedules` | Belum didefinisikan |
| Warta | `/announcements` | Belum didefinisikan |
| Formulir Pelayanan | `/service-forms` | Belum didefinisikan |
| Permohonan Doa | `/prayer-requests` | Belum didefinisikan |
| Donasi | `/donations`, `/church-bank-accounts` | Belum didefinisikan |
| Direktori | `/directory` | Belum didefinisikan |
| Komunitas | `/communities` | Belum didefinisikan |
| Keuangan (read-only) | `/finance/summary` | Belum didefinisikan |
| Media | `/media/sermons`, `/media/hymns` | Belum didefinisikan |
| Profil | `/profile` | Belum didefinisikan |
| Search | `/search` | Belum didefinisikan |

> Detail per endpoint (params, request body, contoh response) ditambahkan
> satu per satu sebelum modul terkait mulai dikerjakan, disepakati bersama
> antara pengembang backend & mobile.
