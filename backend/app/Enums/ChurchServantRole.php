<?php

namespace App\Enums;

enum ChurchServantRole: string
{
    case PdtResort = 'pdt_resort';
    case Sintua = 'sintua';
    case Majelis = 'majelis';
    case SectorLeader = 'sector_leader';
    case FellowshipLeader = 'fellowship_leader';
}
