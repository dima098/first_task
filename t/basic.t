use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Data::Dumper;

my $t = Test::Mojo->new('TestApp');

$t->get_ok('/api/users?sparam=fadaerf')->status_is(200)->json_is({status => 'ok', list => []});
$t->get_ok('/api/users')->status_is(200)->json_has('/list/0/id')->json_has('/list/0/name')->json_has('/list/0/email')->json_has('/list/0/pass')->json_has('/list/0/updated')->json_has('/list/0/created')->json_has('/list/0/image');
done_testing();
