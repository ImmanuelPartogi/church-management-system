<?php

namespace App\Enums;

enum ServiceFormStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Approved = 'approved';
    case Rejected = 'rejected';
}
