package Barcode::QRCode::Data::EightBitByte;
use Any::Moose;
extends 'Barcode::QRCode::Data';

use Barcode::QRCode::Constants qw(:modes);

has '+mode' => ( default => $QR_MODE_8BIT_BYTE );

override 'write_to_buffer' => sub {
    my ($self, $buffer) = @_;
    $buffer->put(ord($_) & 0xff, 8) for split(//, $self->data);
};

no Any::Moose;
1;
