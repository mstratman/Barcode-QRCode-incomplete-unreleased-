use Test::More;
use Barcode::QRCode;
use strict;

my $qr = Barcode::QRCode->new(
    data => 'abc',
    version_number => 1,
    correction_level => 'L',
);

is_deeply(
    $qr->barcode,
    $qr->barcode,
    "Calling barcode() multiple times returns the same results.",
);

done_testing;
