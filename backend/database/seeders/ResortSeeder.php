<?php

namespace Database\Seeders;

use App\Models\Resort;
use Illuminate\Database\Seeder;

class ResortSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $resorts = [
            [
                'name' => 'Resort HKBP Distrik I',
                'code' => 'RES-001',
                'description' => 'Resort HKBP Distrik I',
            ],
        ];

        foreach ($resorts as $resort) {
            Resort::firstOrCreate(
                ['name' => $resort['name']],
                [
                    'code' => $resort['code'],
                    'description' => $resort['description'],
                    'active' => true,
                ]
            );
        }
    }
}
