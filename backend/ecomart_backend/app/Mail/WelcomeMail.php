<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class WelcomeMail extends Mailable
{
    use Queueable, SerializesModels;

    public $token;  // الtoken

    public function __construct($token)
    {
        $this->token = $token;
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Welcome to ecomart!',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.welcome',  // view الemail
            with: ['token' => $this->token],
        );
    }

    public function attachments(): array
    {
        return [];
    }
}