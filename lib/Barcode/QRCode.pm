package Barcode::QRCode;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

use Data::Dumper; #debug TODO:DEBUG
$Data::Dumper::Indent=0;
our $DEBUG = 0;
sub debug { if ($DEBUG) { print(STDERR @_); print STDERR "\n"; }  }

use Barcode::QRCode::Constants qw(
    :modes
    $QR_CORRECTION_LEVEL_MAGIC_NUM
    $QR_PATTERN_POSITION_TABLE
    $QR_RS_BLOCK_TABLE
    $QR_G18 $QR_G15 $QR_G15_MASK
    $QR_PAD0 $QR_PAD1
);
use Barcode::QRCode::VersionNumber qw(min_qr_version);
use Barcode::QRCode::BitBuffer;
use Barcode::QRCode::Math qw(gexp);
use Barcode::QRCode::Polynomial;
use Barcode::QRCode::Data::EightBitByte;
use List::Util qw(max);
use POSIX qw(floor);

our $VERSION = '0.01';

=head1 NAME

Barcode::QRCode - Pure-perl generation of QR Code barcode data

=cut

=head1 SYNOPSIS

    use Barcode::QRCode;

    my $qrcode = Barcode::QRCode->new(data => 'Hello, World');

    # Get a simple array of arrays with true/false values
    my $barcode = $qrcode->barcode;

    # Print a text representation of this barcode
    for my $row (@$barcode) {
        for my $cell (@$row) {
            print $cell ? '#' : ' ';
        }
        print "\n";
    }

=head1 DESCRIPTION

TODO: ...

=cut

# This perl module was initially cargo-culted straight from
# http://d-project.googlecode.com/svn/trunk/misc/qrcode/js/qrcode.js
# It has undergone some minor cleanups to be more perl'ish, but it's still
# very much a work in progress.
#
# I also added the automatic calculation of version_number.

#//---------------------------------------------------------------------
#// QRCode for JavaScript
#//
#// Copyright (c) 2009 Kazuhiko Arase
#//
#// URL: http://www.d-project.com/
#//
#// Licensed under the MIT license:
#//   http://www.opensource.org/licenses/mit-license.php
#//
#// The word "QR Code" is registered trademark of
#// DENSO WAVE INCORPORATED
#//   http://www.denso-wave.com/qrcode/faqpatent-e.html
#//
#//---------------------------------------------------------------------

=head1 ATTRIBUTES

=cut

has 'data' => (
    is      => 'rw',
    default => '',
    trigger => sub { $_[0]->clear_version_number },
    documentation => 'The data to embed in the QR code',
);

has 'mode' => (
    is      => 'ro',
    default => $QR_MODE_8BIT_BYTE,
    isa     => 'Int',
    documentation => 'TODO: Not currently utilized.',
    #documentation => 'Character encoding mode. Default is $QR_MODE_8BIT_BYTE. See :modes in Barcode::QRCode::Constants for more',
);

enum 'CorrectionLevel', [ qw(L M Q H) ];
has 'correction_level' => (
    is       => 'ro',
    isa      => 'CorrectionLevel',
    required => 1,
    default  => 'M',
    documentation => 'Correction level (L, M, Q, or H).  Default is M',
);
sub correction_level_magic_num {
    my $self = shift;
    return $QR_CORRECTION_LEVEL_MAGIC_NUM->{$self->correction_level};
}

has 'version_number' => (
    is       => 'rw',
    isa      => 'Int',
    lazy     => 1,
    clearer  => 'clear_version_number',
    builder  => '_build_version_number',
    trigger => sub { $_[0]->_clear_modules_per_side },
    documentation => 'Auto-calculated by default. 1-40. See http://www.denso-wave.com/qrcode/qrgene2-e.html',
);
sub _build_version_number {
    my $self = shift;
    return min_qr_version($self->data, $self->mode, $self->correction_level);
}

has '_data_cache'   => (is => 'rw');
has '_data_list'    => (is => 'rw', default => sub { [] });
has '_modules'      => (is => 'rw', default => sub { [] });
has '_modules_per_side' => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_modules_per_side',
    clearer => '_clear_modules_per_side',
);
sub _build_modules_per_side {
    my $self = shift;
    ### Symbol version gives us number of modules.
    # (from http://www.denso-wave.com/qrcode/qrgene2-e.html)
    # "Module configuration" refers to the number of modules contained in a
    # symbol, commencing with Version 1 (21 × 21 modules) up to
    # Version 40 (177 × 177 modules).
    # Each higher version number comprises 4 additional modules per side.
    $self->version_number * 4 + 17;
}

=head1 METHODS

=head2 new

TODO: ...

=head2 barcode

TODO: ...

=cut

sub barcode {
    my $self = shift;
    my $data = shift;

    $self->_data_cache(undef);
    $self->_data_list([]);
    $self->_modules([]);

    if (defined $data) {
        $self->data($data);
    } else {
        $data = $self->data;
    }

    # TODO: Conditionally check $self->mode and create the appropriate
    #       Barcode::QRCode::Data::* object.
    my $byte = Barcode::QRCode::Data::EightBitByte->new(data => $data);

    push @{ $self->_data_list }, $byte;
    $self->_data_cache(undef);

    #$self->_make_impl(0, $self->_best_mask_pattern);
    my $bmp = $self->_best_mask_pattern;
$DEBUG=1;
debug("AT THIS POINT _modules is OK\n");
    $self->_make_impl(0, $bmp);
debug(Dumper($self->_modules));
debug("AT THIS POINT _modules is broken\n");

    return $self->_modules;
}

=head1 AUTHOR

Mark A. Stratman, C<< <stratman@gmail.com> >>

=head1 ACKNOWLEDGEMENTS

This perl module was initially cargo-culted straight from
an older version of
L<http://d-project.googlecode.com/svn/trunk/misc/qrcode/js/qrcode.js>
Copyright (c) 2009 Kazuhiko Arase

It has undergone some minor cleanups to be more perl'ish, but it's still
very much a work in progress.

=head1 SOURCE REPOSITORY

L<http://github.com/mstratman/Barcode-QRCode>

=head1 SEE ALSO

=over 4

=item L<HTML::Barcode::QRCode>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 the AUTHORs and CONTRIBUTERS listed above.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut


sub _make_impl {
    my ($self, $test, $mask_pattern) = @_;

    my @modules = ();
    for (1 .. $self->_modules_per_side) {
        push @modules, [ (undef) x $self->_modules_per_side];
    }
    $self->_modules(\@modules);

    $self->_setup_position_probe_pattern(0, 0);
    $self->_setup_position_probe_pattern($self->_modules_per_side - 7, 0);
    $self->_setup_position_probe_pattern(0, $self->_modules_per_side - 7);
    $self->_setup_position_adjust_pattern();
    $self->_setup_timing_pattern();
    $self->_setup_type_info($test, $mask_pattern);

    if ($self->version_number >= 7) {
        $self->_setup_version_number($test);
    }

    unless (defined $self->_data_cache) {
        $self->_data_cache($self->_create_data);
    }

    $self->_map_data($mask_pattern);
    $self->_convert_module_undefs_to_zeros;
}

sub _convert_module_undefs_to_zeros {
    my $self = shift;
    my $mod = $self->_modules;
    for my $i (0 .. $#$mod) {
        for my $j (0 .. $#{ $mod->[$i] }) {
            $mod->[$i]->[$j] = 0 unless defined $mod->[$i]->[$j];
        }
    }
}

sub _setup_position_probe_pattern {
    my ($self, $row, $col) = @_;

    # TODO: magic numbers
    for (my $r = -1; $r <= 7; $r++) {
        next if ($row + $r <= -1 || $self->_modules_per_side <= $row + $r);
        for (my $c = -1; $c <= 7; $c++) {
            next if ($col + $c <= -1 || $self->_modules_per_side <= $col + $c);
            if ((0 <= $r && $r <= 6 && ($c == 0 || $c == 6))
                || (0 <= $c && $c <= 6 && ($r == 0 || $r == 6))
                || (2 <= $r && $r <= 4 && 2 <= $c && $c <= 4) )
            {
                $self->_modules->[$row + $r]->[$col + $c] = 1;
            } else {
                $self->_modules->[$row + $r]->[$col + $c] = 0;
            }
        }
    }
}

# See bitmasking here: http://www.pclviewer.com/rs2/qrmasking.htm
sub _best_mask_pattern {
    my $self = shift;

    my $min_lost_point = 0;
    my $pattern = 0;

    for my $i (0 .. 7) {
        $self->_make_impl(1, $i);

        my $lost_point = $self->_lost_point;
        if ($i == 0 || $min_lost_point > $lost_point) {
            $min_lost_point = $lost_point;
            $pattern = $i;
        }

    }
debug("AT THIS POINT _modules is OK\n");

    return $pattern;
}

sub _lost_point {
    my $self = shift;

    my $modules_per_side = $self->_modules_per_side;
    my $lost_point = 0;

    my $is_dark = sub {
        my ($row, $col) = @_;
        if ($row < 0 || $self->_modules_per_side <= $row || $col < 0 || $self->_modules_per_side <= $col) {
            die "Invalid row,col: " . $row . ',' . $col;
        }
        return $self->_modules->[$row]->[$col];
    };

    # LEVEL1
    for (my $row = 0; $row < $modules_per_side; $row++) {
        for (my $col = 0; $col < $modules_per_side; $col++) {
            my $same_count = 0;
            my $dark = $is_dark->($row, $col);

            for (my $r = -1; $r <= 1; $r++) {
                next if ($row + $r < 0 || $modules_per_side <= $row + $r);
                for (my $c = -1; $c <= 1; $c++) {
                    next if ($col + $c < 0 || $modules_per_side <= $col + $c);
                    next if ($r == 0 && $c == 0);

                    if ($dark == $is_dark->($row + $r, $col + $c) ) {
                        $same_count++;
                    }
                }
            }

            if ($same_count > 5) {
                $lost_point += (3 + $same_count - 5);
            }
        }
    }

    # LEVEL2
    for (my $row = 0; $row < $modules_per_side - 1; $row++) {
        for (my $col = 0; $col < $modules_per_side - 1; $col++) {
            my $count = 0;
            if ($is_dark->($row,     $col    )) { $count++ }
            if ($is_dark->($row + 1, $col    )) { $count++ }
            if ($is_dark->($row,     $col + 1)) { $count++ }
            if ($is_dark->($row + 1, $col + 1)) { $count++ }
            if ($count == 0 || $count == 4) {
                $lost_point += 3;
            }
        }
    }

    # LEVEL3
    for (my $row = 0; $row < $modules_per_side; $row++) {
        for (my $col = 0; $col < $modules_per_side - 6; $col++) {
            if ($is_dark->($row, $col)
                && ! $is_dark->($row, $col + 1)
                &&   $is_dark->($row, $col + 2)
                &&   $is_dark->($row, $col + 3)
                &&   $is_dark->($row, $col + 4)
                && ! $is_dark->($row, $col + 5)
                &&   $is_dark->($row, $col + 6) )
            {
                $lost_point += 40;
            }
        }
    }

    for (my $col = 0; $col < $modules_per_side; $col++) {
        for (my $row = 0; $row < $modules_per_side - 6; $row++) {
            if ($is_dark->($row, $col)
                && ! $is_dark->($row + 1, $col)
                &&   $is_dark->($row + 2, $col)
                &&   $is_dark->($row + 3, $col)
                &&   $is_dark->($row + 4, $col)
                && ! $is_dark->($row + 5, $col)
                &&   $is_dark->($row + 6, $col) )
            {
                $lost_point += 40;
            }
        }
    }

    # LEVEL4

    my $dark_count = 0;

    for (my $col = 0; $col < $modules_per_side; $col++) {
        for (my $row = 0; $row < $modules_per_side; $row++) {
            if ($is_dark->($row, $col) ) {
                $dark_count++;
            }
        }
    }

    # TODO: magic numbers
    my $ratio = abs( (((100 * $dark_count) / $modules_per_side) / $modules_per_side) - 50) / 5;
    $lost_point += $ratio * 10;

    return $lost_point;
}

sub _setup_timing_pattern {
    my $self = shift;

    # TODO: magic numbers
    for (my $r = 8; $r < $self->_modules_per_side - 8; $r++) {
        if (defined $self->_modules->[$r]->[6]) {
            next;
        }
        $self->_modules->[$r]->[6] = ($r % 2 == 0) ? 1 : 0;
    }

    for (my $c = 8; $c < $self->_modules_per_side- 8; $c++) {
        if (defined $self->_modules->[6]->[$c]) {
            next;
        }
        $self->_modules->[6]->[$c] = ($c % 2 == 0) ? 1 : 0;
    }
}

sub _setup_position_adjust_pattern {
    my $self = shift;

    my $pos = $QR_PATTERN_POSITION_TABLE->[$self->version_number - 1];

    for (my $i = 0; $i <= $#$pos; $i++) {
        for (my $j = 0; $j <= $#$pos; $j++) {
            my $row = $pos->[$i];
            my $col = $pos->[$j];

            if (defined $self->_modules->[$row]->[$col]) {
                next;
            }

            # TODO: magic numbers
            for (my $r = -2; $r <= 2; $r++) {
                for (my $c = -2; $c <= 2; $c++) {
                    if ($r == -2 || $r == 2 || $c == -2 || $c == 2
                        || ($r == 0 && $c == 0) )
                    {
                        $self->_modules->[$row + $r]->[$col + $c] = 1;
                    } else {
                        $self->_modules->[$row + $r]->[$col + $c] = 0;
                    }
                }
            }
        }
    }
}

sub _setup_version_number {
    my ($self, $test) = @_;

    my $bits = $self->_get_BCH_version_number;

    my $modules_per_side = $self->_modules_per_side;
    # TODO: magic numbers
    for my $i (0 .. 17) {
        my $mod = (! $test && ( ($bits >> $i) & 1) == 1) ? 1 : 0;
        my $j = floor($i/3);
        my $k = $i % 3 + $modules_per_side - 8 - 3;
        $self->_modules->[$j]->[$k] = $mod;
        $self->_modules->[$k]->[$j] = $mod;
    }
}
sub _get_BCH_version_number {
    my ($self, $version) = @_;
    $version //= $self->version_number;
    my $d = $version << 12;

    while ($self->_get_BCH_digit($d) - $self->_get_BCH_digit($QR_G18) >= 0) {
        $d ^= ($QR_G18 << ($self->_get_BCH_digit($d) - $self->_get_BCH_digit($QR_G18) ) );
    }
    return ($version << 12) | $d;
}

sub _get_BCH_type_info {
    my ($self, $data) = @_;
    my $d = $data << 10;
    while ($self->_get_BCH_digit($d) - $self->_get_BCH_digit($QR_G15) >= 0) {
        $d ^= ($QR_G15 << ($self->_get_BCH_digit($d) - $self->_get_BCH_digit($QR_G15) ) );
    }
    return ( ($data << 10) | $d) ^ $QR_G15_MASK;
}

sub _get_BCH_digit {
    my ($self, $data) = @_;
    my $digit = 0;

    while ($data != 0) {
        $digit++;
        $data >>= 1;
    }

    return $digit;
}

sub _setup_type_info {
    my ($self, $test, $mask) = @_;

    my $data = ($self->correction_level_magic_num << 3) | $mask;
    my $bits = $self->_get_BCH_type_info($data);

    # vertical
    for my $i (0 .. 14) {
        my $mod = (! $test && ( ($bits >> $i) & 1) == 1) ? 1 : 0;

        if ($i < 6) {
            $self->_modules->[$i]->[8] = $mod;
        } elsif ($i < 8) {
            $self->_modules->[$i + 1]->[8] = $mod;
        } else {
            $self->_modules->[$self->_modules_per_side - 15 + $i]->[8] = $mod;
        }
    }

    # horizontal
    for my $i (0 .. 15) {
        my $mod = (! $test && ( ($bits >> $i) & 1) == 1) ? 1 : 0;

        if ($i < 8) {
            $self->_modules->[8]->[$self->_modules_per_side - $i - 1] = $mod;
        } elsif ($i == 8) {
            $self->_modules->[8]->[15 - $i - 1 + 1] = $mod;
        } else {
            $self->_modules->[8]->[15 - $i - 1] = $mod;
        }
    }

    # fixed module
    $self->_modules->[$self->_modules_per_side - 8]->[8] = ! $test ? 1 : 0;
}

sub _map_data {
    my ($self, $mask_pattern) = @_;

    my $data = $self->_data_cache;
    my $inc = -1;
    my $row = $self->_modules_per_side - 1;
    my $bit_index = 7;
    my $byte_index = 0;

    for (my $col = $self->_modules_per_side - 1; $col > 0; $col -= 2) {
        if ($col == 6) {
            $col--;
        }

        while (1) {
            for my $c (0 .. 1) {
#if ($DEBUG) { print STDERR "working $row, " . ($col - $c) . " ..... " . $self->_modules->[$row]->[$col - $c]; };
                unless (defined $self->_modules->[$row]->[$col - $c]) {
#if ($DEBUG) { print STDERR " - DOING THIS ONE\n" }
                    my $dark = 0;

                    if ($byte_index < scalar(@$data)) {
                        $dark = defined($data->[$byte_index]) && ( ( ($data->[$byte_index] >> $bit_index) & 1) == 1);
                    }

                    my $mask = $self->_get_mask($mask_pattern, $row, $col - $c);
                    if ($mask) {
                        $dark = !$dark;
                    }

                    $self->_modules->[$row]->[$col - $c] = $dark ? 1 : 0;
                    $bit_index--;

                    if ($bit_index == -1) {
                        $byte_index++;
                        $bit_index = 7;
                    }
                }
            }

            $row += $inc;

#debug("       $row < 0 || " . $self->_modules_per_side . " <= $row");
            if ($row < 0 || $self->_modules_per_side <= $row) {
                $row -= $inc;
                $inc = -$inc;
#debug("inc flipped: $row .. $inc");
                last;
            }
        }
#debug("after inc flip");
    }
}

sub _get_RS_blocks {
    my $self = shift;

    my $rs_block;
    my $v = $self->version_number;
    if ($self->correction_level eq 'L') {
        $rs_block = $QR_RS_BLOCK_TABLE->[($v - 1) * 4 + 0];
    } elsif ($self->correction_level eq 'M') {
        $rs_block = $QR_RS_BLOCK_TABLE->[($v - 1) * 4 + 1];
    } elsif ($self->correction_level eq 'Q') {
        $rs_block = $QR_RS_BLOCK_TABLE->[($v - 1) * 4 + 2];
    } elsif ($self->correction_level eq 'H') {
        $rs_block = $QR_RS_BLOCK_TABLE->[($v - 1) * 4 + 3];
    }

    my $length = scalar(@$rs_block) / 3; # will be 1 or 2

    my $list = [];

    for my $i (0 .. ($length - 1)) {
        my $count = $rs_block->[$i * 3 + 0];
        my $total_count = $rs_block->[$i * 3 + 1];
        my $data_count  = $rs_block->[$i * 3 + 2];

        for my $j (0 .. ($count - 1)) {
            push @$list, {
                total_count => $total_count,
                data_count  => $data_count,
            };
        }
    }

    return $list;
};

sub _create_data {
    my $self = shift;

    my $rs_blocks = $self->_get_RS_blocks;
    my $buffer = Barcode::QRCode::BitBuffer->new;

    for my $data (@{ $self->_data_list }) {
        $buffer->put($data->mode, 4);
        $buffer->put($data->get_length, $data->bit_length($self->version_number));
        $data->write_to_buffer($buffer);
    }

    #// calc num max data.
    my $total_data_count = 0;
    for my $i (0 .. $#$rs_blocks) {
        $total_data_count += $rs_blocks->[$i]->{data_count};
    }

    if ($buffer->bit_length > $total_data_count * 8) {
        die "code length overflow.";
    }

    #// end code
    if ($buffer->bit_length + 4 <= $total_data_count * 8) {
        $buffer->put(0, 4);
    }

    #// padding
    while ($buffer->bit_length % 8 != 0) {
        $buffer->put_bit(0);
    }

    #// padding
    while (1) {
        if ($buffer->bit_length >= $total_data_count * 8) {
            last;
        }
        $buffer->put($QR_PAD0, 8);

        if ($buffer->bit_length >= $total_data_count * 8) {
            last;
        }
        $buffer->put($QR_PAD1, 8);
    }

    my $offset = 0;
    my $max_dc_count = 0;
    my $max_ec_count = 0;

    my $dc_data = [];
    my $ec_data = [];

    for my $r (0 .. $#$rs_blocks) {
        my $dc_count = $rs_blocks->[$r]->{data_count};
        my $ec_count = $rs_blocks->[$r]->{total_count} - $dc_count;

        $dc_data->[$r] = [];

        $max_dc_count = max($max_dc_count, $dc_count);
        $max_ec_count = max($max_ec_count, $ec_count);

        for my $i (0 .. ($dc_count - 1)) {
            $dc_data->[$r]->[$i] = 0xff & $buffer->buffer->[$i + $offset];
        }
        $offset += $dc_count;

        my $rs_poly = Barcode::QRCode::Polynomial->new(
            raw_components => [1],
        );
        for my $i (0 .. ($ec_count - 1)) {
            $rs_poly = $rs_poly->multiply(
                Barcode::QRCode::Polynomial->new(
                    raw_components => [1, gexp($i) ],
                )
            );
        }

        my $raw_poly = Barcode::QRCode::Polynomial->new(
            raw_components => $dc_data->[$r],
            shift_val      => (scalar(@{ $rs_poly->components }) - 1),
        );

        my $mod_poly = $raw_poly->mod($rs_poly);

        $ec_data->[$r] = [ (undef) x (scalar(@{ $rs_poly->components }) - 1) ];
        for my $i (0 .. (scalar(@{$rs_poly->components}) - 2)) {
            my $mod_index = $i + scalar(@{ $mod_poly->components }) - scalar(@{ $ec_data->[$r] });
            $ec_data->[$r]->[$i] = ($mod_index >= 0) ? $mod_poly->components->[$mod_index] : 0;
        }

    }

    my $total_code_count = 0;
    for my $rs_block (@$rs_blocks) {
        $total_code_count += $rs_block->{total_count};
    }

    # TODO: Is this necessary? And if not, remove that whole last block,
    my $data = [ map { undef } (1 .. $total_code_count) ];

    my $index = 0;
    for (my $i = 0; $i < $max_dc_count; $i++) {
        for my $r (0 .. $#$rs_blocks) {
            if ($i < scalar(@{ $dc_data->[$r] })) {
                $data->[$index++] = $dc_data->[$r]->[$i];
            }
        }
    }

    for (my $i = 0; $i < $max_ec_count; $i++) {
        for my $r (0 .. $#$rs_blocks) {
            if ($i < scalar(@{ $ec_data->[$r] })) {
                $data->[$index++] = $ec_data->[$r]->[$i];
            }
        }
    }

    return $data;
}

sub _get_mask {
    # $p is mask pattern. i is row.  j is column
    my ($self, $p, $i, $j) = @_;

    if ($p == 0)    { return ($i + $j) % 2 == 0 }                        # 000
    elsif ($p == 1) { return $i % 2 == 0 }                               # 001
    elsif ($p == 2) { return $j % 3 == 0 }                               # 010
    elsif ($p == 3) { return ($i + $j) % 3 == 0 }                        # 011
    elsif ($p == 4) { return (floor($i / 2) + floor($j / 3) ) % 2 == 0 } # 100
    elsif ($p == 5) { return ($i * $j) % 2 + ($i * $j) % 3 == 0 }        # 101
    elsif ($p == 6) { return ( ($i * $j) % 2 + ($i * $j) % 3) % 2 == 0 } # 110
    elsif ($p == 7) { return ( ($i * $j) % 3 + ($i + $j) % 2) % 2 == 0 } # 111

    die "Bad mask pattern: $p";
}

no Any::Moose;
1;
