use strict;
use warnings;
use Module::Build;
use Alien::FFCall;

# Add the WIN32 compiler flag, as appropriate
my $compiler_flags = Alien::FFCall->cflags();
$compiler_flags .= ' -DWIN32' if $^O eq "MSWin32";

# Add the specific libraries against which to link
my $linker_flags = Alien::FFCall->libs();

# Create the build script:
my $builder = Module::Build->new(
	module_name => 'FFI',
	extra_compiler_flags => $compiler_flags,
	extra_linker_flags => $linker_flags,
	configure_requires => {
		'Alien::FFCall' => 0,
	},
	meta_merge => {
		resources  => {
			repository => "http://github.com/run4flat/perlffi",
			bugtracker => "http://github.com/run4flat/perlffi/issues",
		},
	},
);
$builder->create_build_script;
