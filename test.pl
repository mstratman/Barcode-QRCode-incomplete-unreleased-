#!/usr/bin/env perl
use common::sense;
use lib './lib';
   use Barcode::QRCode;

    my $qrcode = Barcode::QRCode->new(
        data => 'abc',
        version_number => 1,
        correction_level => 'L',
    );
    #my $qrcode = Barcode::QRCode->new(data => 'H');

    # Get a simple array of arrays with true/false values
    my $barcode = $qrcode->barcode;

use Data::Dumper;
print Dumper($barcode);
exit;
    # Print a text representation of this barcode
    for my $row (@$barcode) {
        for my $cell (@$row) {
            print $cell ? '#' : ' ';
        }
        print "\n";
    }
