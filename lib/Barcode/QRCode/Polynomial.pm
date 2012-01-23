package Barcode::QRCode::Polynomial;
use Any::Moose;
use Barcode::QRCode::Math qw(glog gexp);

has 'raw_components' => (
    is       => 'ro',
    required => 1,
    isa     => 'ArrayRef[Maybe[Num]]',
);
has 'shift_val' => (
    is      => 'ro',
    default => 0,
);

has 'components' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_components',
);
sub _build_components {
    my $self = shift;
    my $raw_components = $self->raw_components;

    my $offset = 0;
    while ($offset < scalar(@$raw_components) && $raw_components->[$offset] == 0) {
        $offset++;
    }

    my $rv = [ (0) x (scalar(@$raw_components) - $offset + $self->shift_val) ];
    for my $i (0 .. ($#$raw_components - $offset)) {
        $rv->[$i] = $raw_components->[$i + $offset];
    }
    return $rv;
}


sub multiply {
    my ($self, $e) = @_;

    my $num = [ (0) x (scalar(@{ $self->components }) + scalar(@{ $e->components }) - 1) ];

    for my $i (0 .. $#{ $self->components }) {
        for my $j (0 .. $#{ $e->components }) {
            $num->[$i + $j] ^= gexp(
                glog( $self->components->[$i] )
                + glog( $e->components->[$j] )
            );
        }
    }

    return Barcode::QRCode::Polynomial->new(
        raw_components => $num,
        shift_val      => 0,
    );
}

sub mod {
    my ($self, $e) = @_;

    if (scalar(@{ $self->components }) - scalar(@{ $e->components }) < 0) {
        return $self;
    }

    my $ratio = glog($self->components->[0]) - glog($e->components->[0]);

    my $num = [ (0) x scalar(@{ $self->components }) ];

    for my $i (0 .. $#{ $self->components }) {
        $num->[$i] = $self->components->[$i];
    }
    for my $i (0 .. $#{ $e->components }) {
        $num->[$i] ^= gexp(glog($e->components->[$i]) + $ratio);
    }

    return Barcode::QRCode::Polynomial->new(
        raw_components => $num,
        shift_val      => 0,
    )->mod($e);
}


no Any::Moose;
1;
