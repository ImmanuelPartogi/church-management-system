<?php

namespace Database\Seeders;

use App\Models\ServiceFormType;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class ServiceFormTypeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $formTypes = [
            [
                'name' => 'Baptis',
                'description' => 'Formulir Pendaftaran Baptisan Kudus (Anak/Dewasa)',
                'fee_amount' => 0,
            ],
            [
                'name' => 'Sidi',
                'description' => 'Formulir Pendaftaran Peneguhan Sidi',
                'fee_amount' => 0,
            ],
            [
                'name' => 'Nikah',
                'description' => 'Formulir Pemberkatan Pernikahan Kudus',
                'fee_amount' => 0,
            ],
            [
                'name' => 'Konseling',
                'description' => 'Formulir Permohonan Konseling Pastoral',
                'fee_amount' => 0,
            ],
            [
                'name' => 'Pindah Masuk',
                'description' => 'Formulir Pendaftaran Anggota Jemaat Pindah Masuk',
                'fee_amount' => 0,
            ],
            [
                'name' => 'Pindah Keluar',
                'description' => 'Formulir Permohonan Surat Pindah Jemaat',
                'fee_amount' => 0,
            ],
        ];

        foreach ($formTypes as $type) {
            ServiceFormType::firstOrCreate(
                ['slug' => Str::slug($type['name'])],
                [
                    'name' => $type['name'],
                    'description' => $type['description'],
                    'fee_amount' => $type['fee_amount'],
                    'active' => true,
                ]
            );
        }
    }
}
