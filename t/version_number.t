use Test::More;
use Barcode::QRCode::Constants qw(:modes $QR_PATTERN_POSITION_TABLE);

BEGIN { use_ok('Barcode::QRCode::VersionNumber', 'min_qr_version') }

is(min_qr_version('Hello, World', $QR_MODE_ALPHA_NUM, 'L'), 1, '12 chars, alphanum, L => level 1');
is(min_qr_version('Hello, World', $QR_MODE_ALPHA_NUM, 'H'), 2, '12 chars, alphanum, H => level 2');
is(min_qr_version(join('', ('x' x 1852)), $QR_MODE_ALPHA_NUM, 'H'), 40, '1852 chars, alphanum, H => level 40');
is(min_qr_version(join('', ('x' x 1853)), $QR_MODE_ALPHA_NUM, 'H'), undef, '1852 chars, alphanum, H => undef');

# TODO: Test other modes, and more scenarios

done_testing;
