package FFI::Library;

use strict;
use Carp;
use vars qw($VERSION);
use FFI;

$VERSION = '0.01';

sub new {
  my $class = shift;
  my $libname = shift;
  scalar(@_) <= 1
    or croak 'Usage: $lib = new FFI::Library($filename [, $flags])';
  my $so = $libname;
  -e $so or $so = DynaLoader::dl_findfile($libname) || $libname;
  my $lib = DynaLoader::dl_load_file($so, @_)
    or return undef;
  bless \$lib, $class;
}

sub DESTROY {
  DynaLoader::dl_free_file(${$_[0]})
    if defined (&DynaLoader::dl_free_file);
}

sub function {
    my $self = shift;
    my $name = shift;
    my $sig = shift;
    my $addr = DynaLoader::dl_find_symbol(${$self}, $name);
    croak "Unknown function $name" unless defined $addr;

    sub { FFI::call($addr, $sig, @_); }
}

1;
__END__

=head1 NAME

FFI::Library - Perl Access to Dynamically Loaded Libraries

=head1 SYNOPSIS

    use FFI::Library;
    $lib = FFI::Library->new("mylib");
    $fn = $lib->function("fn", "signature");
    $ret = $fn->(...);

=head1 DESCRIPTION

This module provides access from Perl to functions exported from dynamically
linked libraries. Functions are described by C<signatures>, for details of
which see the L<FFI> module's documentation.

=head1 EXAMPLES

    $clib_file = ($^O eq "MSWin32") ? "MSVCRT40.DLL" : "-lc";
    $clib = FFI::Library->new($clib_file);
    $strlen = $clib->function("strlen", "cIp");
    $n = $strlen->($my_string);

=head1 TODO

=head1 LICENSE

This module can be distributed under the same terms as Perl. However, as it
depends on the L<FFI> module, please note the licensing terms for the FFI
code.

=head1 AUTHOR

Paul Moore, gustav@morpheus.demon.co.uk

=head1 SEE ALSO

The L<FFI> module.

=cut
