<?php

namespace Database\Seeders;

use App\Models\Announcement;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;

class AnnouncementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Announcement::create([
            'title' => 'Church Anniversary Celebration',
            'content' => 'Join us next Sunday as we celebrate our 25th Church Anniversary! There will be a special lunch fellowship after the second service.',
            'image' => 'https://images.unsplash.com/photo-1548625361-155deee223d5',
            'published_at' => Carbon::now()->subDays(5),
            'status' => 'published',
        ]);

        Announcement::create([
            'title' => 'New Members Class',
            'content' => 'If you are new to our church and want to know more about our ministries, statement of faith, and how to become a registered member, sign up for the upcoming class starting this Saturday.',
            'image' => null,
            'published_at' => Carbon::now()->subDay(),
            'status' => 'published',
        ]);

        Announcement::create([
            'title' => 'Renovation Project Update',
            'content' => 'Here is the draft update regarding our chapel renovation project phase 2. More details will be shared once finalized.',
            'image' => null,
            'published_at' => null,
            'status' => 'draft',
        ]);
    }
}
