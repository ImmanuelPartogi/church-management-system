<?php

namespace App\Notifications\Registration;

use App\Models\ChurchRegistration;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ChurchRegistrationRejectedNotification extends Notification
{
    use Queueable;

    public function __construct(
        public ChurchRegistration $registration,
        public string $reason
    ) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Status Pendaftaran Gereja: '.$this->registration->church_name)
            ->greeting('Halo '.$this->registration->applicant_name.',')
            ->line('Terima kasih telah mengajukan pendaftaran untuk **'.$this->registration->church_name.'**.')
            ->line('Setelah dilakukan peninjauan oleh tim Sinode, mohon maaf permohonan pendaftaran gereja Anda **belum dapat disetujui** saat ini.')
            ->line('**Alasan:**')
            ->line('> '.$this->reason)
            ->line('Jika Anda membutuhkan informasi lebih lanjut atau ingin memperbaiki data permohonan, silakan hubungi Kantor Pusat Sinode.');
    }
}
