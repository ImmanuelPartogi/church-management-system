# Church Management System

Sistem manajemen gereja: aplikasi mobile untuk jemaat (Flutter) + Web Admin
untuk pengurus/majelis (Laravel + Filament), dengan satu REST API sebagai
sumber data tunggal.

## Struktur Repo

```
church-management-system/
├── backend/     # Laravel 12 — REST API + Web Admin (Filament)
├── mobile/      # Flutter — aplikasi jemaat
├── docs/        # dokumentasi bersama (API contract, dll)
└── .github/     # CI, PR & issue template, CODEOWNERS
```

Dokumentasi setup masing-masing ada di README folder terkait:
- [`backend/README.md`](backend/README.md)
- [`mobile/README.md`](mobile/README.md)

## Status

**Fase Setup Awal** — struktur proyek, arsitektur, dan tooling sudah siap.
Implementasi fitur bisnis (Authentication, Jadwal Ibadah, Warta, Formulir
Pelayanan, Donasi, Direktori, Keuangan, Media, dll) menyusul di fase
pengembangan berikutnya.

## Workflow Kolaborasi

```
main (produksi, stabil, protected)
  └── develop (integrasi, protected)
        ├── feature/*
        ├── bugfix/*
        ├── refactor/*
        └── docs/*
```

- Semua pekerjaan dimulai dari `develop`, lewat branch `feature/*`,
  `bugfix/*`, `refactor/*`, atau `docs/*`.
- Tidak ada commit langsung ke `main` atau `develop` — wajib Pull Request
  + minimal 1 review.
- Commit message mengikuti [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`).

## CI

Dua workflow terpisah, masing-masing hanya berjalan saat ada perubahan di
foldernya:
- `.github/workflows/backend-ci.yml` — Pint, Larastan, PHPUnit
- `.github/workflows/mobile-ci.yml` — `dart format`, `flutter analyze`, `flutter test`

## Kontrak API

Sebelum sebuah modul mulai dikerjakan (backend & mobile paralel), endpoint
dan bentuk request/response-nya disepakati dulu di
[`docs/api-contract.md`](docs/api-contract.md).
