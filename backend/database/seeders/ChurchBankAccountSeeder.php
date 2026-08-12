<?php

namespace Database\Seeders;

use App\Models\ChurchBankAccount;
use Illuminate\Database\Seeder;

class ChurchBankAccountSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $accounts = [
            [
                'bank_name' => 'Bank Mandiri',
                'account_number' => '1230009876543',
                'account_holder_name' => 'Gereja HKBP Resort',
                'is_active' => true,
                'display_order' => 1,
            ],
            [
                'bank_name' => 'BCA',
                'account_number' => '8880123456',
                'account_holder_name' => 'Gereja HKBP Resort',
                'is_active' => true,
                'display_order' => 2,
            ],
        ];

        foreach ($accounts as $account) {
            ChurchBankAccount::firstOrCreate(
                ['account_number' => $account['account_number']],
                [
                    'bank_name' => $account['bank_name'],
                    'account_holder_name' => $account['account_holder_name'],
                    'is_active' => $account['is_active'],
                    'display_order' => $account['display_order'],
                ]
            );
        }
    }
}
