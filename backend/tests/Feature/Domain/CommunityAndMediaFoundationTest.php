<?php

namespace Tests\Feature\Domain;

use App\Enums\ChurchServantRole;
use App\Models\ChurchMember;
use App\Models\ChurchServant;
use App\Models\Fellowship;
use App\Models\Resort;
use App\Models\Sector;
use App\Models\Sermon;
use App\Models\Song;
use App\Models\Songbook;
use App\Models\User;
use Database\Seeders\FellowshipSeeder;
use Database\Seeders\ResortSeeder;
use Database\Seeders\SectorSeeder;
use Database\Seeders\SongbookSeeder;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CommunityAndMediaFoundationTest extends TestCase
{
    use RefreshDatabase;

    // ─── SECTOR & RESORT ────────────────────────────────────────────

    public function test_resort_can_be_created_and_filtered_by_active_scope(): void
    {
        $active = Resort::factory()->create(['active' => true]);
        $inactive = Resort::factory()->create(['active' => false]);

        $results = Resort::active()->get();

        $this->assertTrue($results->contains($active));
        $this->assertFalse($results->contains($inactive));
    }

    public function test_sector_belongs_to_resort(): void
    {
        $resort = Resort::factory()->create();
        $sector = Sector::factory()->create(['resort_id' => $resort->id]);

        $this->assertTrue($sector->resort->is($resort));
        $this->assertTrue($resort->sectors->contains($sector));
    }

    public function test_sector_active_scope_filters_correctly(): void
    {
        $resort = Resort::factory()->create();
        $active = Sector::factory()->create(['resort_id' => $resort->id, 'active' => true]);
        $inactive = Sector::factory()->create(['resort_id' => $resort->id, 'active' => false]);

        $results = Sector::active()->get();

        $this->assertTrue($results->contains($active));
        $this->assertFalse($results->contains($inactive));
    }

    // ─── FELLOWSHIP ─────────────────────────────────────────────────

    public function test_fellowship_can_be_created_and_filtered_by_active_scope(): void
    {
        $active = Fellowship::factory()->create(['active' => true]);
        $inactive = Fellowship::factory()->create(['active' => false]);

        $results = Fellowship::active()->get();

        $this->assertTrue($results->contains($active));
        $this->assertFalse($results->contains($inactive));
    }

    public function test_member_belongs_to_many_fellowships(): void
    {
        $member = ChurchMember::factory()->create(['user_id' => User::factory()]);
        $fellowship1 = Fellowship::factory()->create();
        $fellowship2 = Fellowship::factory()->create();

        $member->fellowships()->attach([$fellowship1->id, $fellowship2->id]);

        $this->assertCount(2, $member->fellowships);
        $this->assertTrue($member->fellowships->contains($fellowship1));
        $this->assertTrue($member->fellowships->contains($fellowship2));
    }

    public function test_fellowship_has_many_members(): void
    {
        $fellowship = Fellowship::factory()->create();
        $member1 = ChurchMember::factory()->create(['user_id' => User::factory()]);
        $member2 = ChurchMember::factory()->create(['user_id' => User::factory()]);

        $fellowship->members()->attach([$member1->id, $member2->id]);

        $this->assertCount(2, $fellowship->members);
        $this->assertTrue($fellowship->members->contains($member1));
    }

    // ─── CHURCH SERVANT ─────────────────────────────────────────────

    public function test_church_servant_casts_role_to_enum(): void
    {
        $servant = ChurchServant::factory()->create([
            'role' => ChurchServantRole::Sintua,
        ]);

        $this->assertInstanceOf(ChurchServantRole::class, $servant->role);
        $this->assertEquals(ChurchServantRole::Sintua, $servant->role);
    }

    public function test_church_servant_belongs_to_member(): void
    {
        $member = ChurchMember::factory()->create(['user_id' => User::factory()]);
        $servant = ChurchServant::factory()->create(['member_id' => $member->id]);

        $this->assertTrue($servant->member->is($member));
        $this->assertTrue($member->servantProfile->is($servant));
    }

    public function test_church_servant_can_be_assigned_to_resort_and_sector(): void
    {
        $resort = Resort::factory()->create();
        $sector = Sector::factory()->create(['resort_id' => $resort->id]);

        $servant = ChurchServant::factory()->inSector($sector)->create();

        $this->assertTrue($servant->resort->is($resort));
        $this->assertTrue($servant->sector->is($sector));
        $this->assertTrue($resort->servants->contains($servant));
        $this->assertTrue($sector->servants->contains($servant));
    }

    public function test_church_servant_can_be_assigned_to_fellowship(): void
    {
        $fellowship = Fellowship::factory()->create();

        $servant = ChurchServant::factory()->inFellowship($fellowship)->create([
            'role' => ChurchServantRole::FellowshipLeader,
        ]);

        $this->assertTrue($servant->fellowship->is($fellowship));
        $this->assertTrue($fellowship->servants->contains($servant));
    }

    public function test_church_servant_active_scope(): void
    {
        $active = ChurchServant::factory()->create(['active' => true]);
        $inactive = ChurchServant::factory()->create(['active' => false]);

        $results = ChurchServant::active()->get();

        $this->assertTrue($results->contains($active));
        $this->assertFalse($results->contains($inactive));
    }

    // ─── SERMON ─────────────────────────────────────────────────────

    public function test_sermon_can_be_created_with_publication_status(): void
    {
        $published = Sermon::factory()->create([
            'is_published' => true,
            'published_at' => now()->subDay(),
        ]);
        $unpublished = Sermon::factory()->unpublished()->create();

        $results = Sermon::published()->get();

        $this->assertTrue($results->contains($published));
        $this->assertFalse($results->contains($unpublished));
    }

    public function test_sermon_belongs_to_servant(): void
    {
        $servant = ChurchServant::factory()->create([
            'role' => ChurchServantRole::PdtResort,
        ]);
        $sermon = Sermon::factory()->byServant($servant)->create();

        $this->assertTrue($sermon->servant->is($servant));
        $this->assertTrue($servant->sermons->contains($sermon));
    }

    // ─── SONGBOOK & SONG ───────────────────────────────────────────

    public function test_songbook_has_many_songs(): void
    {
        $songbook = Songbook::factory()->create();
        $song1 = Song::factory()->create(['songbook_id' => $songbook->id, 'number' => 1]);
        $song2 = Song::factory()->create(['songbook_id' => $songbook->id, 'number' => 2]);

        $this->assertCount(2, $songbook->songs);
        $this->assertTrue($songbook->songs->contains($song1));
    }

    public function test_song_belongs_to_songbook(): void
    {
        $songbook = Songbook::factory()->create();
        $song = Song::factory()->create(['songbook_id' => $songbook->id]);

        $this->assertTrue($song->songbook->is($songbook));
    }

    public function test_song_number_is_unique_within_songbook(): void
    {
        $songbook = Songbook::factory()->create();
        Song::factory()->create(['songbook_id' => $songbook->id, 'number' => 42]);

        $this->expectException(QueryException::class);

        Song::factory()->create(['songbook_id' => $songbook->id, 'number' => 42]);
    }

    public function test_same_number_allowed_in_different_songbooks(): void
    {
        $songbook1 = Songbook::factory()->create();
        $songbook2 = Songbook::factory()->create();

        $song1 = Song::factory()->create(['songbook_id' => $songbook1->id, 'number' => 1]);
        $song2 = Song::factory()->create(['songbook_id' => $songbook2->id, 'number' => 1]);

        $this->assertEquals(1, $song1->number);
        $this->assertEquals(1, $song2->number);
        $this->assertNotEquals($song1->songbook_id, $song2->songbook_id);
    }

    public function test_songbook_active_scope(): void
    {
        $active = Songbook::factory()->create(['active' => true]);
        $inactive = Songbook::factory()->create(['active' => false]);

        $results = Songbook::active()->get();

        $this->assertTrue($results->contains($active));
        $this->assertFalse($results->contains($inactive));
    }

    // ─── SEEDERS ────────────────────────────────────────────────────

    public function test_community_and_media_seeders_populate_initial_records(): void
    {
        $this->seed([
            ResortSeeder::class,
            SectorSeeder::class,
            FellowshipSeeder::class,
            SongbookSeeder::class,
        ]);

        $this->assertDatabaseHas('resorts', ['code' => 'RES-001']);
        $this->assertDatabaseHas('sectors', ['name' => 'Sektor 1']);
        $this->assertDatabaseHas('sectors', ['name' => 'Sektor 2']);
        $this->assertDatabaseHas('sectors', ['name' => 'Sektor 3']);
        $this->assertDatabaseHas('fellowships', ['code' => 'PNBR']);
        $this->assertDatabaseHas('fellowships', ['code' => 'KI']);
        $this->assertDatabaseHas('fellowships', ['code' => 'KB']);
        $this->assertDatabaseHas('fellowships', ['code' => 'SKM']);
        $this->assertDatabaseHas('songbooks', ['code' => 'BE']);
        $this->assertDatabaseHas('songbooks', ['code' => 'BN']);
        $this->assertDatabaseHas('songbooks', ['code' => 'KJ']);
    }
}
