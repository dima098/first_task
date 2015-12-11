package TestApp::Controller::Api;
use Mojo::Base 'Mojolicious::Controller';

sub api {
	my $self = shift;
	my $param = $self->param('sparam');
	my $dbh = $self->db;
	my $query;
	my $arrJson = [];

	if ($param ne '') {
		$query = $dbh->prepare('select * from users where name like \'%'.$param.'%\' or email like \'%'.$param.'%\'');
	} else {
		$query = $dbh->prepare('select * from users');
	}

	$query->execute();
	
	while (my $hash = $query->fetchrow_hashref) {
		push $arrJson, $hash;
	}

	$self->render(json => {status => 'ok', list => $arrJson});
};

1;