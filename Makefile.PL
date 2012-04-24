use inc::Module::Install;

name     'Barcode-QRCode';
all_from 'lib/Barcode/QRCode.pm';
author   q{Mark A. Stratman <stratman@gmail.com>};
license  'perl';

requires 'Moo' => 0; # Eventually this should probably be the release afte 0.009014 (or some time after that), for greater moose compatibility
requires 'Scalar::Util' => 0;
requires 'List::Util'   => 0;
requires 'Try::Tiny'    => 0;
requires 'POSIX'        => 0;

test_requires 'Test::More' => 0;
test_requires 'FindBin' => 0;
test_requires 'File::Spec' => 0;

auto_install;

WriteAll;

