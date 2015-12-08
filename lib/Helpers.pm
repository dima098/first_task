package TestApp::Helpers;
use base 'Mojolicious::Plugin';

sub register {
	my ($c, $app) = @_;

	$app->helper(logged => sub {});
	$app->helper(user => sub {});
}

1;