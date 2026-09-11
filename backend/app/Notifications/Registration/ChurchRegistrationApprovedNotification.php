<?php

namespace App\Notifications\Registration;

use App\Models\Church;
use App\Models\ChurchRegistration;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ChurchRegistrationApprovedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public ChurchRegistration $registration,
        public Church $church
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $loginUrl = url('/admin/login');

        return (new MailMessage)
            ->subject('Pendaftaran Gereja Disetujui: '.$this->church->name)
            ->greeting('Selamat, '.$this->registration->applicant_name.'!')
            ->line('Pendaftaran **'.$this->church->name.'** telah diverifikasi dan **disetujui** oleh Super Admin Sinode.')
            ->line('Akun Anda telah diangkat sebagai **Administrator Gereja (church_admin)** untuk '.$this->church->name.'.')
            ->line('Seluruh modul operasional dasar gereja telah otomatis dikonfigurasi dan siap digunakan.')
            ->action('Masuk ke Portal Admin Gereja', $loginUrl)
            ->line('Gunakan email Anda ('.$this->registration->applicant_email.') dan kata sandi yang Anda tentukan saat pendaftaran.')
            ->line('Tuhan memberkati pelayanan Anda dan gereja.');
    }
}
