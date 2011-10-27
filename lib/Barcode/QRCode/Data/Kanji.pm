package Barcode::QRCode::Data::Kanji;
use Any::Moose;
extends 'Barcode::QRCode::Data';

use POSIX qw(floor);
use Barcode::QRCode::Constants qw(:modes);

has '+mode' => ( default => $QR_MODE_KANJI );

override 'get_length' => sub {
    my ($self) = @_;
    return floor(length($self->data) / 2);
};

override 'write_to_buffer' => sub {
    my ($self, $buffer) = @_;
    die "TODO";

    my $i = 0;
    while ($i + 1 < length($self->data)) {
    }

};

no Any::Moose;
1;
