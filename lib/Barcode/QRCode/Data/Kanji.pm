package Barcode::QRCode::Data::Kanji;
use Moo;
extends 'Barcode::QRCode::Data';

use POSIX qw(floor);
use Barcode::QRCode::Constants qw(:modes);

sub _build_mode { $QR_MODE_KANJI }

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

1;
