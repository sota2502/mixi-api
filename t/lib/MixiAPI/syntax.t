use strict;
use warnings;
use Test::More;

use File::Find::Rule;

my $rule = File::Find::Rule->new();
$rule->name('*.pm');

foreach my $file ( $rule->in( 'lib' ) ) {
    $file =~ s/(lib\/|\.pm)//g;
    $file =~ s/\//::/g;
    use_ok( $file );
}


done_testing;
