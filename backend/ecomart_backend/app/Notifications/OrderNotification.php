<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use NotificationChannels\Telegram\TelegramMessage;

class OrderNotification extends Notification
{
    use Queueable;

    private $message;  

    public function __construct($message)
    {
        $this->message = $message;
    }

    public function via($notifiable)
    {
        return ['telegram'];  
    }
public function toTelegram($notifiable)
{
    return TelegramMessage::create()
        ->to($notifiable->telegram_chat_id)  // chat_id من User
        ->content($this->message)  // الرسالة
        ->button('عرض الطلب', 'http://yourapp.com/order');  // زر تفاعلي
}
}