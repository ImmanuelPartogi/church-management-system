<?php

namespace App\Enums;

enum DonationStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Approved = 'approved';
    case Rejected = 'rejected';
}
