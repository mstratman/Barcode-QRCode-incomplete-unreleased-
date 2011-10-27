package Barcode::QRCode::Constants;
use strict;
use warnings;
use Readonly; # install Readonly::XS for better performance

require Exporter;
our @ISA = qw(Exporter);

Readonly::Scalar our $QR_MODE_NUMBER    => 0x01;
Readonly::Scalar our $QR_MODE_ALPHA_NUM => 0x02;
Readonly::Scalar our $QR_MODE_8BIT_BYTE => 0x04;
Readonly::Scalar our $QR_MODE_KANJI     => 0x08;

# TODO: Figure out what this is, document it, and name it appropriately
Readonly::Scalar our $QR_CORRECTION_LEVEL_MAGIC_NUM => {
    L => 1,
    M => 0,
    Q => 3,
    H => 2,
};

Readonly::Scalar our $QR_PAD0 => 0xEC;
Readonly::Scalar our $QR_PAD1 => 0x11;

Readonly::Scalar our $QR_G15_MASK => (1 << 14) | (1 << 12) | (1 << 10) | (1 << 4) | (1 << 1);
Readonly::Scalar our $QR_G15 => (1 << 10) | (1 << 8) | (1 << 5) | (1 << 4) | (1 << 2) | (1 << 1) | (1 << 0);
Readonly::Scalar our $QR_G18 => (1 << 12) | (1 << 11) | (1 << 10) | (1 << 9) | (1 << 8) | (1 << 5) | (1 << 2) | (1 << 0);

Readonly::Scalar our $QR_RS_BLOCK_TABLE => [

    # L
    # M
    # Q
    # H

    # 1
    [1, 26, 19],
    [1, 26, 16],
    [1, 26, 13],
    [1, 26, 9],

    # 2
    [1, 44, 34],
    [1, 44, 28],
    [1, 44, 22],
    [1, 44, 16],

    # 3
    [1, 70, 55],
    [1, 70, 44],
    [2, 35, 17],
    [2, 35, 13],

    # 4
    [1, 100, 80],
    [2, 50, 32],
    [2, 50, 24],
    [4, 25, 9],

    # 5
    [1, 134, 108],
    [2, 67, 43],
    [2, 33, 15, 2, 34, 16],
    [2, 33, 11, 2, 34, 12],

    # 6
    [2, 86, 68],
    [4, 43, 27],
    [4, 43, 19],
    [4, 43, 15],

    # 7
    [2, 98, 78],
    [4, 49, 31],
    [2, 32, 14, 4, 33, 15],
    [4, 39, 13, 1, 40, 14],

    # 8
    [2, 121, 97],
    [2, 60, 38, 2, 61, 39],
    [4, 40, 18, 2, 41, 19],
    [4, 40, 14, 2, 41, 15],

    # 9
    [2, 146, 116],
    [3, 58, 36, 2, 59, 37],
    [4, 36, 16, 4, 37, 17],
    [4, 36, 12, 4, 37, 13],

    # 10
    [2, 86, 68, 2, 87, 69],
    [4, 69, 43, 1, 70, 44],
    [6, 43, 19, 2, 44, 20],
    [6, 43, 15, 2, 44, 16]
];

Readonly::Scalar our $QR_PATTERN_POSITION_TABLE => [
    [],
    [6, 18],
    [6, 22],
    [6, 26],
    [6, 30],
    [6, 34],
    [6, 22, 38],
    [6, 24, 42],
    [6, 26, 46],
    [6, 28, 50],
    [6, 30, 54],
    [6, 32, 58],
    [6, 34, 62],
    [6, 26, 46, 66],
    [6, 26, 48, 70],
    [6, 26, 50, 74],
    [6, 30, 54, 78],
    [6, 30, 56, 82],
    [6, 30, 58, 86],
    [6, 34, 62, 90],
    [6, 28, 50, 72, 94],
    [6, 26, 50, 74, 98],
    [6, 30, 54, 78, 102],
    [6, 28, 54, 80, 106],
    [6, 32, 58, 84, 110],
    [6, 30, 58, 86, 114],
    [6, 34, 62, 90, 118],
    [6, 26, 50, 74, 98, 122],
    [6, 30, 54, 78, 102, 126],
    [6, 26, 52, 78, 104, 130],
    [6, 30, 56, 82, 108, 134],
    [6, 34, 60, 86, 112, 138],
    [6, 30, 58, 86, 114, 142],
    [6, 34, 62, 90, 118, 146],
    [6, 30, 54, 78, 102, 126, 150],
    [6, 24, 50, 76, 102, 128, 154],
    [6, 28, 54, 80, 106, 132, 158],
    [6, 32, 58, 84, 110, 136, 162],
    [6, 26, 54, 82, 110, 138, 166],
    [6, 30, 58, 86, 114, 142, 170],
];

our %EXPORT_TAGS = (
    modes => [ qw(
        $QR_MODE_NUMBER
        $QR_MODE_ALPHA_NUM
        $QR_MODE_8BIT_BYTE
        $QR_MODE_KANJI
    ) ],
);

{
    my %seen;
    push @{$EXPORT_TAGS{all}},
            grep { ! $seen{$_}++ }
            @{ $EXPORT_TAGS{$_} }
        for keys %EXPORT_TAGS;
}

our @EXPORT_OK = qw(
    $QR_PATTERN_POSITION_TABLE
    $QR_RS_BLOCK_TABLE
    $QR_CORRECTION_LEVEL_MAGIC_NUM
    $QR_G15
    $QR_G18
    $QR_G15_MASK
    $QR_PAD0
    $QR_PAD1
);
Exporter::export_ok_tags(qw(all modes));

1;
