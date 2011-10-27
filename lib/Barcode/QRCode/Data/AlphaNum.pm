package Barcode::QRCode::Data::AlphaNum;
use Any::Moose;
extends 'Barcode::QRCode::Data';

use POSIX qw(floor);
use Barcode::QRCode::Constants qw(:modes);

has '+mode' => ( default => $QR_MODE_ALPHA_NUM );

override 'write_to_buffer' => sub {
    my ($self, $buffer) = @_;
    die "TODO";
};

no Any::Moose;
1;
