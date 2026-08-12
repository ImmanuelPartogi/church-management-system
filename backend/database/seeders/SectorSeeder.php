<?php

namespace Database\Seeders;

use App\Models\Resort;
use App\Models\Sector;
use Illuminate\Database\Seeder;

class SectorSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $resort = Resort::first();

        $sectors = [
            [
                'name' => 'Sektor 1',
                'code' => 'SEK-01',
                'description' => 'Sektor wilayah 1',
            ],
            [
                'name' => 'Sektor 2',
                'code' => 'SEK-02',
                'description' => 'Sektor wilayah 2',
            ],
            [
                'name' => 'Sektor 3',
                'code' => 'SEK-03',
                'description' => 'Sektor wilayah 3',
            ],
        ];

        foreach ($sectors as $sector) {
            Sector::firstOrCreate(
                [
                    'resort_id' => $resort?->id,
                    'name' => $sector['name'],
                ],
                [
                    'code' => $sector['code'],
                    'description' => $sector['description'],
                    'active' => true,
                ]
            );
        }
    }
}
