<?php

namespace App\Enums;

enum ServiceFormStatus: string
{
    case Draft = 'draft';
    case Pending = 'pending';
    case Processing = 'processing';
    case SectorVerified = 'sector_verified';
    case PastorApproved = 'pastor_approved';
    case Approved = 'approved';
    case Rejected = 'rejected';
    case Completed = 'completed';
}
