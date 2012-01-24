#!/usr/bin/env perl
use common::sense;
use lib '.', './lib';
use MyQRCode;

my $qrcode = MyQRCode->new(
    #text => 'abc',
    #version_number => 1,
    #correction_level => 'L',
text => 'The quick brown fox jumps over the lazy dog',
version_number => 4,
correction_level => 'Q',
);
say $qrcode->render;
