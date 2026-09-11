<?php

namespace App\Notifications\Registration;

use App\Models\ChurchRegistration;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Illuminate\Support\Facades\URL;

class ChurchRegistrationVerifyNotification extends Notification
{
    use Queueable;

    public function __construct(
        public ChurchRegistration $registration
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        // Sole Authoritative Cryptographic Gate: HMAC signed URL valid for 24 hours
        $verificationUrl = URL::temporarySignedRoute(
            'public.church-registration.verify',
            now()->addHours(24),
            ['registration' => $this->registration->id]
        );

        return (new MailMessage)
            ->subject('Verifikasi Email Pendaftaran Gereja: '.$this->registration->church_name)
            ->greeting('Halo '.$this->registration->applicant_name.',')
            ->line('Terima kasih telah mendaftarkan **'.$this->registration->church_name.'** ke Sistem Informasi Gereja.')
            ->line('Untuk memverifikasi kepemilikan alamat email Anda dan meneruskan permohonan ke tim Kantor Pusat / Sinode, silakan klik tombol di bawah ini:')
            ->action('Verifikasi Email Pendaftaran', $verificationUrl)
            ->line('Tautan verifikasi ini berlaku selama 24 jam.')
            ->line('Jika Anda tidak merasa melakukan pendaftaran ini, abaikan email ini.');
    }
}
