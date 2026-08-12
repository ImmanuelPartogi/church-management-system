<?php

namespace App\Enums;

enum PrayerRequestStatus: string
{
    case Submitted = 'submitted';
    case Prayed = 'prayed';
    case FollowedUp = 'followed_up';
}
