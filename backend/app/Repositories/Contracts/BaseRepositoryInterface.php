<?php

namespace App\Repositories\Contracts;

/**
 * Kontrak dasar repository. Setiap modul (Schedule, Announcement,
 * ServiceForm, Donation, dst) punya interface sendiri yang extend ini,
 * lalu diimplementasikan di app/Repositories/<Module>Repository.php.
 *
 * Baik API Controller maupun Filament Resource WAJIB mengakses data lewat
 * Service layer -> Repository layer ini, bukan lewat Eloquent Model
 * langsung, supaya business logic tidak terduplikasi di dua tempat.
 *
 * @template TModel
 */
interface BaseRepositoryInterface
{
    public function all(array $filters = []): mixed;

    public function find(int|string $id): mixed;

    public function create(array $data): mixed;

    public function update(int|string $id, array $data): mixed;

    public function delete(int|string $id): bool;
}
