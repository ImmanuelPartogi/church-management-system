<?php

namespace App\Models;

use Database\Factories\ServiceFormDocumentFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'service_form_application_id',
    'document_name',
    'file_path',
    'file_name',
    'mime_type',
    'file_size',
])]
class ServiceFormDocument extends Model
{
    /** @use HasFactory<ServiceFormDocumentFactory> */
    use HasFactory;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'file_size' => 'integer',
        ];
    }

    /**
     * Get the service form application associated with this document.
     *
     * @return BelongsTo<ServiceFormApplication, $this>
     */
    public function application(): BelongsTo
    {
        return $this->belongsTo(ServiceFormApplication::class, 'service_form_application_id');
    }
}
