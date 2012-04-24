package Barcode::QRCode::Data::EightBitByte;
use Moo;
extends 'Barcode::QRCode::Data';

use Barcode::QRCode::Constants qw(:modes);

sub _build_mode { $QR_MODE_8BIT_BYTE }

sub write_to_buffer {
    my ($self, $buffer) = @_;
    $buffer->put(ord($_) & 0xff, 8) for split(//, $self->data);
}

1;
