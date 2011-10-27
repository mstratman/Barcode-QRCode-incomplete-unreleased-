use inc::Module::Install;

name     'Barcode-QRCode';
all_from 'lib/Barcode/QRCode.pm';
author   q{Mark A. Stratman <stratman@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'Any::Moose'   => '0.15';
requires 'Scalar::Util' => 0;
requires 'List::Util'   => 0;
requires 'Try::Tiny'    => 0;
requires 'POSIX'        => 0;

auto_install;

WriteAll;

