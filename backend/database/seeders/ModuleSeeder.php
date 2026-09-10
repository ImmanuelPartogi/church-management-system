<?php

namespace Database\Seeders;

use App\Models\Module;
use Illuminate\Database\Seeder;

class ModuleSeeder extends Seeder
{
    /**
     * The 12 official platform modules and their specifications.
     *
     * @var array<int, array{key: string, name: string, is_core: bool, depends_on: ?string, description: string}>
     */
    public const MODULES = [
        // Core Modules (is_core = true)
        [
            'key' => 'announcements',
            'name' => 'Pengumuman Gereja',
            'is_core' => true,
            'depends_on' => null,
            'description' => 'Saluran informasi dan pengumuman pastoral gereja.',
        ],
        [
            'key' => 'membership',
            'name' => 'Jemaat & Keanggotaan',
            'is_core' => true,
            'depends_on' => null,
            'description' => 'Manajemen database anggota jemaat, keluarga, dan profil keanggotaan.',
        ],

        // Independent Feature Modules
        [
            'key' => 'warta',
            'name' => 'Warta Jemaat Digital',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Publikasi warta jemaat mingguan dan distribusi dokumen PDF.',
        ],
        [
            'key' => 'finance',
            'name' => 'Keuangan & Buku Kas',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Bagan akun (COA), rekening bank gereja, buku kas, dan transparansi keuangan.',
        ],
        [
            'key' => 'hymns',
            'name' => 'Buku Nyanyian & Pujian',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Katalog lagu gereja (Buku Ende, Kidung Jemaat, Nyanyikanlah Nyanyian Baru).',
        ],
        [
            'key' => 'daily_verse',
            'name' => 'Ayat Harian',
            'is_core' => false,
            'depends_on' => null,
            'description' => 'Renungan dan ayat harian firman Tuhan untuk aplikasi mobile.',
        ],

        // Dependent Modules (Tier 1)
        [
            'key' => 'schedules',
            'name' => 'Jadwal Ibadah & Kegiatan',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Jadwal ibadah mingguan, acara gereja, dan petugas pelayanan liturgi.',
        ],
        [
            'key' => 'forms',
            'name' => 'Formulir Layanan Sakramen',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Permohonan layanan pastoral, baptis, sidi, nikah kudus, dan atestasi.',
        ],
        [
            'key' => 'prayer_requests',
            'name' => 'Permohonan Doa',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Permohonan pokok doa jemaat dan catatan tindak lanjut pastoral.',
        ],
        [
            'key' => 'community',
            'name' => 'Komunitas & Pelayanan Sektor',
            'is_core' => false,
            'depends_on' => 'membership',
            'description' => 'Struktur resort, sektor kategorial wilayah, persekutuan kategorial, dan pelayan sintua.',
        ],
        [
            'key' => 'donations',
            'name' => 'Donasi & Persembahan Online',
            'is_core' => false,
            'depends_on' => 'finance',
            'description' => 'Konfirmasi transfer persembahan perpuluhan, syukur, dan donasi khusus.',
        ],

        // Dependent Modules (Tier 2)
        [
            'key' => 'sermons',
            'name' => 'Khotbah & Media Audio',
            'is_core' => false,
            'depends_on' => 'community',
            'description' => 'Arsip khotbah mingguan, rekaman audio, dan unduhan materi renungan.',
        ],
    ];

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. First pass: Seed all modules without foreign key depends_on
        foreach (self::MODULES as $item) {
            Module::updateOrCreate(
                ['key' => $item['key']],
                [
                    'name' => $item['name'],
                    'is_core' => $item['is_core'],
                    'description' => $item['description'],
                ]
            );
        }

        // 2. Second pass: Link depends_on to parent module IDs
        foreach (self::MODULES as $item) {
            if ($item['depends_on'] !== null) {
                $parentId = Module::where('key', $item['depends_on'])->value('id');
                Module::where('key', $item['key'])->update(['depends_on' => $parentId]);
            }
        }
    }
}
