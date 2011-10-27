package Barcode::QRCode::QR8bitByte;
use Any::Moose;

use Barcode::QRCode::Constants qw(:modes);

has 'mode' => (
    is => 'ro',
    default => $QR_MODE_8BIT_BYTE,
);
has 'data' => (
    is       => 'rw',
    required => 1,
);
    

no Any::Moose;
1;
