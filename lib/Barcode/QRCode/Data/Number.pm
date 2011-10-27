package Barcode::QRCode::Data::Number;
use Any::Moose;
extends 'Barcode::QRCode::Data';

use Barcode::QRCode::Constants qw(:modes);

has '+mode' => ( default => $QR_MODE_NUMBER );

override 'write_to_buffer' => sub {
    my ($self, $buffer) = @_;

    my $i = 0;
    while ($i + 2 < length($self->data)) {
        $buffer->put(int($self->data), 10);
        $i += 3;
    }

    if ($i < length($self->data)) {
        if (length($self->data) - $i == 1) {
            my $num = substr($self->data, $i, $i + 1);
            $buffer->put(int($num), 4);
        } elsif (length($self->data) - $i == 2) {
            my $num = substr($self->data, $i, $i + 2);
            $buffer->put(int($num), 7);
        }
    }

};

no Any::Moose;
1;
