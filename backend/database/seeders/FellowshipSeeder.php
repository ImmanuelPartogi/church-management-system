<?php

namespace Database\Seeders;

use App\Models\Fellowship;
use Illuminate\Database\Seeder;

class FellowshipSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $fellowships = [
            [
                'name' => 'PNB/R',
                'code' => 'PNBR',
                'description' => 'Persekutuan Naposo Bulung / Remaja',
            ],
            [
                'name' => 'Kaum Ibu',
                'code' => 'KI',
                'description' => 'Persekutuan Kaum Ibu',
            ],
            [
                'name' => 'Kaum Bapak',
                'code' => 'KB',
                'description' => 'Persekutuan Kaum Bapak',
            ],
            [
                'name' => 'SKM',
                'code' => 'SKM',
                'description' => 'Serikat Kaum Muda',
            ],
        ];

        foreach ($fellowships as $fellowship) {
            Fellowship::firstOrCreate(
                ['name' => $fellowship['name']],
                [
                    'code' => $fellowship['code'],
                    'description' => $fellowship['description'],
                    'active' => true,
                ]
            );
        }
    }
}
