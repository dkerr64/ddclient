use Test::More;
use File::Spec::Functions;
use File::Temp;
eval { require Test::MockModule; } or plan(skip_all => $@);
SKIP: { eval { require Test::Warnings; } or skip($@, 1); }
eval { require 'ddclient'; } or BAIL_OUT($@);

my $warning;

my $module = Test::MockModule->new('ddclient');
$module->redefine('warning', sub {
    BAIL_OUT("warning already logged") if defined($warning);
    $warning = sprintf(shift, @_);
});
my $tmpdir = File::Temp->newdir();
my $dir = $tmpdir->dirname();
diag("temporary directory: $dir");
my $ro_tmpdir = File::Temp->newdir();
my $ro_dir = $ro_tmpdir->dirname();
chmod(0500, $ro_dir) or BAIL_OUT($!);
diag("temporary read-only directory: $ro_dir");

sub tc {
    return {
        name => shift,
        f => shift,
        warning_regex => shift,
    };
}

my @test_cases = (
    tc("create cache file",    catfile($dir, 'a', 'b', 'cachefile'),        undef),
    tc("overwrite cache file", catfile($dir, 'a', 'b', 'cachefile'),        undef),
    tc("bad directory",        catfile($dir, 'a', 'b', 'cachefile', 'bad'), qr/File exists/),
    tc("read-only directory",  catfile($ro_dir, 'cachefile'),               qr/Permission denied/),
);

for my $tc (@test_cases) {
    $warning = undef;
    ddclient::write_cache($tc->{f});
    subtest $tc->{name} => sub {
        if (defined($tc->{warning_regex})) {
            like($warning, $tc->{warning_regex}, "expected warning message");
        } else {
            ok(!defined($warning), "no warning");
            ok(-f $tc->{f}, "cache file exists");
        }
    };
}

done_testing();
