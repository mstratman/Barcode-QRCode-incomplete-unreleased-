#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Barcode::QRCode' ) || print "Bail out!\n";
}

diag( "Testing Barcode::QRCode $Barcode::QRCode::VERSION, Perl $], $^X" );
