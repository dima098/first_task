use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('TestApp');
$t->get_ok('/users')->status_is(200);

done_testing();
