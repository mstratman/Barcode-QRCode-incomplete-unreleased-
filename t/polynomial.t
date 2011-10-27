use Test::More;
use Barcode::QRCode::Math;
use Try::Tiny;
# TODO: Maybe get rid of ::Polynomial class altogether

BEGIN { use_ok('Barcode::QRCode::Polynomial') }

# Test $p1->multiply($p2) == $p3
{
    # These are just taken from some sample console.log()'ing on the qrcode.js
    my $mult_p1_p2_p3 = [
        [
            [1],
            [1, 1],
            [1, 1]
        ],
        [
            [1, 1],
            [1, 2],
            [1, 3, 2]
        ],
        [
            [1, 3, 2],
            [1, 4],
            [1, 7, 14, 8],
        ],
        [
            [1, 7, 14, 8],
            [1, 8],
            [1, 15, 54, 120, 64],
        ],
        [
            [1, 15, 54, 120, 64],
            [1, 16],
            [1, 31, 198, 63, 147, 116],
        ],
        [
            [1, 226, 207, 158, 245, 235, 164, 232, 197, 37],
            [1, 58],
            [1, 216, 194, 159, 111, 199, 94, 95, 113, 157, 193],
        ],
        [
            [1, 68, 119, 67, 118, 220, 31, 7, 84, 92, 127, 213, 97],
            [1, 205],
            [1, 137, 73, 227, 17, 177, 17, 52, 13, 46, 43, 83, 132, 120],
        ],
    ];

    my $i = 1;
    for my $data (@$mult_p1_p2_p3) {
        my $p1 = Barcode::QRCode::Polynomial->new(raw_components => $data->[0]);
        my $p2 = Barcode::QRCode::Polynomial->new(raw_components => $data->[1]);
        my $p3 = $p1->multiply($p2);
        is_deeply($p3->components, $data->[2], "multiply() test " . $i++);
    }
}

# Test $p1->mod($p2) == $p3
{
    # These values were, again, just taken from watching what was going on in qrcode.js
    my $p1 = Barcode::QRCode::Polynomial->new(
        raw_components => [
            64, 19, 0, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17, 236, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef
        ],
        shift_val => 18,
    );
    my $p2 = Barcode::QRCode::Polynomial->new(
        raw_components => [
            1, 239, 251, 183, 113, 149, 175, 199, 215, 240, 220, 73, 82, 173, 75, 32, 67, 217, 146,
        ],
        shift_val => 0,
    );
    my $p3 = $p1->mod($p2);
    is_deeply(
        $p3->components, 
        [31, 146, 75, 136, 59, 181, 162, 132, 73, 177, 200, 73, 101, 24, 108, 132, 60, 137],
        'mod() test 1'
    );
}

done_testing;
