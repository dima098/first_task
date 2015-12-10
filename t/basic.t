use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('TestApp');
$t->get_ok('/test')->status_is(200)->json_content_is({status => "ok"});

done_testing();
