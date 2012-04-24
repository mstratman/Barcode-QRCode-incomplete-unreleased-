package Barcode::QRCode::Data::AlphaNum;
use Moo;
extends 'Barcode::QRCode::Data';

use Barcode::QRCode::Constants qw(:modes);

sub _build_mode { $QR_MODE_ALPHA_NUM }

override 'write_to_buffer' => sub {
    my ($self, $buffer) = @_;
    die "TODO";
};

1;
