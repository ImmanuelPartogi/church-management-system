<?php

namespace Database\Seeders;

use App\Models\Church;
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
        if (! app()->bound('current_church_id') || app('current_church_id') === null) {
            $defaultChurch = Church::firstOrCreate(
                ['slug' => (string) config('tenant.default_church_slug', 'default')],
                [
                    'uuid' => (string) Str::uuid(),
                    'name' => 'Gereja HKBP Resort Default',
                    'status' => 'active',
                    'timezone' => 'Asia/Jakarta',
                ]
            );
            app()->instance('current_church_id', $defaultChurch->id);
            app()->instance('current_church', $defaultChurch);
        }

        $formTypes = [
            [
                'name' => 'Baptis',
                'description' => 'Formulir Pendaftaran Baptisan Kudus (Anak/Dewasa)',
                'fee_amount' => 0,
                'is_sacrament' => true,
            ],
            [
                'name' => 'Sidi',
                'description' => 'Formulir Pendaftaran Peneguhan Sidi',
                'fee_amount' => 0,
                'is_sacrament' => true,
            ],
            [
                'name' => 'Nikah',
                'description' => 'Formulir Pemberkatan Pernikahan Kudus',
                'fee_amount' => 0,
                'is_sacrament' => true,
            ],
            [
                'name' => 'Konseling',
                'description' => 'Formulir Permohonan Konseling Pastoral',
                'fee_amount' => 0,
                'is_sacrament' => false,
            ],
            [
                'name' => 'Pindah Masuk',
                'description' => 'Formulir Pendaftaran Anggota Jemaat Pindah Masuk',
                'fee_amount' => 0,
                'is_sacrament' => false,
            ],
            [
                'name' => 'Pindah Keluar',
                'description' => 'Formulir Permohonan Surat Pindah Jemaat',
                'fee_amount' => 0,
                'is_sacrament' => false,
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
                    'is_sacrament' => $type['is_sacrament'],
                ]
            );
        }
    }
}
