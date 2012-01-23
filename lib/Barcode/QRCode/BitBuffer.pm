package Barcode::QRCode::BitBuffer;
use Any::Moose;
use POSIX qw(floor);

has 'buffer' => (
    is      => 'ro',
    default => sub { [] },
);
has 'bit_length' => (
    is      => 'rw',
    default => 0,
);

sub get {
    my ($self, $i) = @_;

    my $buf_index = floor($i / 8);
    return ( ($self->buffer->[$buf_index] >> (7 - $i % 8) ) & 1) == 1;
}

sub put {
    my ($self, $num, $len) = @_;
    for my $i (0 .. ($len - 1)) {
        $self->put_bit( ( ($num >> ($len - $i - 1) ) & 1) == 1);
    }
}

sub put_bit {
    my ($self, $bit) = @_;

    my $buf_index = floor($self->bit_length / 8);

    if (scalar(@{ $self->buffer }) <= $buf_index) {
        push @{ $self->buffer }, 0;
    }

    if ($bit) {
        $self->buffer->[$buf_index] |= (0x80 >> ($self->bit_length % 8) );
    }

    $self->bit_length( $self->bit_length + 1 );
}

no Any::Moose;
1;
