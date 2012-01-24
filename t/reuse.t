use strict;
use Test::More;
use Barcode::QRCode;
use FindBin;
use File::Spec;
BEGIN { push @INC, File::Spec->catfile($FindBin::Bin, 'lib') }
use SampleData;

# Compare some outputs of this library to that of the PHP and JS libraries.


my $sample1 = SampleData::sample_L1();
my $qr = Barcode::QRCode->new(
    %{ $sample1->{input} },
);
# Gotten from the php library:
is_deeply(
    $qr->barcode,
    $sample1->{output},
    "Version 1, L correction - before reuse",
);

my $sample2 = SampleData::sample_L2();
$qr->data($sample2->{input}->{data});
is($qr->version_number, 2, "Version increased to match larger text");
is_deeply(
    $qr->barcode,
    $sample2->{output},
    "Version 2, L correction with reused QRCode object"
);

done_testing;
