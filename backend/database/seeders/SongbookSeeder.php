<?php

namespace Database\Seeders;

use App\Models\Songbook;
use Illuminate\Database\Seeder;

class SongbookSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $songbooks = [
            [
                'name' => 'Buku Ende',
                'code' => 'BE',
                'description' => 'Buku Ende HKBP',
            ],
            [
                'name' => 'Buku Nyanyian',
                'code' => 'BN',
                'description' => 'Buku Nyanyian Gereja',
            ],
            [
                'name' => 'Kidung Jemaat',
                'code' => 'KJ',
                'description' => 'Kidung Jemaat',
            ],
        ];

        foreach ($songbooks as $songbook) {
            Songbook::firstOrCreate(
                ['code' => $songbook['code']],
                [
                    'name' => $songbook['name'],
                    'description' => $songbook['description'],
                    'active' => true,
                ]
            );
        }
    }
}
