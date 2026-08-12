<?php

namespace Database\Seeders;

use App\Enums\FinanceAccountType;
use App\Models\ChartOfAccount;
use Illuminate\Database\Seeder;

class ChartOfAccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $accounts = [
            // INCOME ACCOUNTS (4000 series)
            [
                'code' => '4000',
                'name' => 'Persembahan Minggu',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan persembahan ibadah minggu',
            ],
            [
                'code' => '4100',
                'name' => 'Persepuluhan',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan persepuluhan jemaat',
            ],
            [
                'code' => '4200',
                'name' => 'Pembangunan',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan dana pembangunan gereja',
            ],
            [
                'code' => '4300',
                'name' => 'Diakonia',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan persembahan sosial diakonia',
            ],
            [
                'code' => '4400',
                'name' => 'Ucapan Syukur',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan ucapan syukur jemaat',
            ],
            [
                'code' => '4500',
                'name' => 'Donasi',
                'type' => FinanceAccountType::Income,
                'description' => 'Penerimaan donasi khusus',
            ],

            // EXPENSE ACCOUNTS (5000 series)
            [
                'code' => '5000',
                'name' => 'Operasional',
                'type' => FinanceAccountType::Expense,
                'description' => 'Pengeluaran operasional sekretariat gereja',
            ],
            [
                'code' => '5100',
                'name' => 'Gaji & Sentra',
                'type' => FinanceAccountType::Expense,
                'description' => 'Pengeluaran gaji dan tunjangan pelayan',
            ],
            [
                'code' => '5200',
                'name' => 'Listrik',
                'type' => FinanceAccountType::Expense,
                'description' => 'Pengeluaran tagihan listrik gereja',
            ],
            [
                'code' => '5300',
                'name' => 'Air',
                'type' => FinanceAccountType::Expense,
                'description' => 'Pengeluaran tagihan air gereja',
            ],
            [
                'code' => '5400',
                'name' => 'Pemeliharaan',
                'type' => FinanceAccountType::Expense,
                'description' => 'Pemeliharaan gedung dan peralatan gereja',
            ],
            [
                'code' => '5500',
                'name' => 'Kegiatan Gereja',
                'type' => FinanceAccountType::Expense,
                'description' => 'Biaya pelaksanaan kegiatan perayaan & kategorial',
            ],
            [
                'code' => '5600',
                'name' => 'Bantuan Diakonia',
                'type' => FinanceAccountType::Expense,
                'description' => 'Penyaluran bantuan diakonia kepada jemaat',
            ],
        ];

        foreach ($accounts as $account) {
            ChartOfAccount::firstOrCreate(
                ['code' => $account['code']],
                [
                    'name' => $account['name'],
                    'type' => $account['type'],
                    'description' => $account['description'],
                    'is_active' => true,
                ]
            );
        }
    }
}
