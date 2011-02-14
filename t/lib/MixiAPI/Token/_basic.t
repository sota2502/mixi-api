use strict;
use warnings;

use Test::More;

my $class = 'MixiAPI::Token';

use_ok($class);
isa_ok($class, 'MixiAPI::Base');

can_ok($class, qw/
    source
    lookup
    create
    refresh
    is_expired
    _expire
    _number_timestamp
/);

done_testing;
