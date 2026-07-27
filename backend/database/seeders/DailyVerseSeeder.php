<?php

namespace Database\Seeders;

use App\Models\DailyVerse;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class DailyVerseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Seeding for yesterday
        DailyVerse::create([
            'verse_reference' => 'Psalm 23:1',
            'content' => 'The Lord is my shepherd; I shall not want.',
            'date' => Carbon::today()->subDay()->toDateString(),
        ]);

        // Seeding for today
        DailyVerse::create([
            'verse_reference' => 'John 3:16',
            'content' => 'For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.',
            'date' => Carbon::today()->toDateString(),
        ]);

        // Seeding for tomorrow
        DailyVerse::create([
            'verse_reference' => 'Romans 8:28',
            'content' => 'And we know that for those who love God all things work together for good, for those who are called according to his purpose.',
            'date' => Carbon::today()->addDay()->toDateString(),
        ]);
    }
}
