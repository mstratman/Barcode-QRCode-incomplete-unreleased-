use strict;
use Test::More;
use Barcode::QRCode;
use FindBin;
use File::Spec;
BEGIN { push @INC, File::Spec->catfile($FindBin::Bin, 'lib') }
use SampleData;

my $sanity_checks = 0;

# Compare static javascript output with static php output. No need to keep 
# doing this so it's disabled now.
# But it was useful because we're testing our Perl output against some
# static values, so we need to know those static values are reproducable.
if ($sanity_checks) {
    my $sj = SampleData::sample_L1_from_JS();
    my $sp = SampleData::sample_L1_from_PHP();
    is_deeply(
        $sj->{output},
        $sp->{output},
        "Sanity check 1 - JS vs PHP output"
    );

    $sj = SampleData::sample_Q4_from_JS();
    $sp = SampleData::sample_Q4_from_PHP();
    is_deeply(
        $sj->{output},
        $sp->{output},
        "Sanity check 2 - JS vs PHP output"
    );
}


# Now... Compare some outputs of this library with those produced by
# the PHP and/or JS libraries.

{
    my $s = SampleData::sample_L1();
    my $qr = Barcode::QRCode->new(%{ $s->{input} });
    is_deeply(
        $qr->barcode,
        $s->{output},
        "Version 1, L correction",
    );
}


{
    my $s = SampleData::sample_L2();
    my $qr = Barcode::QRCode->new(%{ $s->{input} });
    is_deeply(
        $qr->barcode,
        $s->{output},
        "Version 2, L correction",
    );
}

{
    my $s = SampleData::sample_Q4();
    my $qr = Barcode::QRCode->new(%{ $s->{input} });
    is_deeply(
        $qr->barcode,
        $s->{output},
        "Version 4, Q correction",
    );
}

done_testing;
