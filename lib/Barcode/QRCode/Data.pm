package Barcode::QRCode::Data;
use Moo;

use Barcode::QRCode::Constants qw(:modes);

has 'data' => (
    is       => 'ro',
    required => 1,
);
has 'mode' => (
    is      => 'ro',
    builder => '_build_mode',
);
sub _build_mode { undef }

sub is_number    { $_[0]->mode == $QR_MODE_NUMBER }
sub is_alpha_num { $_[0]->mode == $QR_MODE_ALPHA_NUM }
sub is_8bit_byte { $_[0]->mode == $QR_MODE_8BIT_BYTE }
sub is_kanji     { $_[0]->mode == $QR_MODE_KANJI }

sub bit_length {
    my ($self, $version_number) = @_;

    if ($version_number >= 1 && $version_number < 10) {
        if    ($self->is_number)    { return 10 }
        elsif ($self->is_alpha_num) { return 9 }
        elsif ($self->is_8bit_byte) { return 8 }
        elsif ($self->is_kanji)     { return 8 }

    } elsif ($version_number < 27) {
        if    ($self->is_number)    { return 12 }
        elsif ($self->is_alpha_num) { return 11 }
        elsif ($self->is_8bit_byte) { return 16 }
        elsif ($self->is_kanji)     { return 10 }

    } elsif ($version_number < 41) {
        if    ($self->is_number)    { return 14 }
        elsif ($self->is_alpha_num) { return 11 }
        elsif ($self->is_8bit_byte) { return 16 }
        elsif ($self->is_kanji)     { return 10 }
    }
    return undef;
}

sub get_length {
    my $self = shift;
    return length($self->data);
}

sub write_to_buffer { die "Not implemented" }

1;
