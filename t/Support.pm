use Config;
require DynaLoader;

# Convenience functions wrapping DynaLoader

sub load {
    my $name = shift;
    my $so = $name;
    -e $so or $so = DynaLoader::dl_findfile($name) || $name;
    DynaLoader::dl_load_file($so, @_);
}

sub unload {
    DynaLoader::dl_free_file($_[0])
        if defined (&DynaLoader::dl_free_file);
}

sub address {
    DynaLoader::dl_find_symbol($_[0], $_[1]);
}

# Get the libc and libm libraries

use vars qw($libc $libm);

$libc = load($Config{'libc'} || "-lc");

if (!$libc) {
  if ($^O =~ /win32/i) {
    $libc = load("MSVCRT40") || load("MSVCRT20");
  } elsif ($^O =~ /linux/i) {
    # Some glibc versions install "libc.so" as a linker script,
    # unintelligible to dlopen().
    $libc = load("libc.so.6");
  }
}

if (!$libc) {
  die "Can't load -lc: ", DynaLoader::dl_error(), "\nGiving up.\n";
}

my $libm_arg = DynaLoader::dl_findfile("-lm");
if (!$libm_arg) {
  $libm = $libc;
} elsif ($libm_arg !~ /libm\.a$/) {
  $libm = load("-lm");
}

if (!$libm) {
  die "Can't load -lm: ", DynaLoader::dl_error(), "\nGiving up.\n";
}

END {
    unload($libm);
    unload($libc);
}

1;
