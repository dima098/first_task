package TestApp::Controller::Auth;
use Mojo::Base 'Mojolicious::Controller';

sub check {
	my $self = shift;
	$self->logged;
 };

sub authorisation {
	my $self = shift;

	my $dbh      = $self->db;
	my $email    = $self->param('email');
	my $password = ($self->param('password'));
	my $query    = $dbh->prepare('select * from users where email=? and pass=?');
	$query->execute($email, $password);

	if ($query->rows > 0) {

		while (my $hash = $query->fetchrow_hashref) {
			$self->session(id => $hash->{id});
			$self->session(email => $hash->{email});
		}

		$self->session(expiration => 604800);
		$self->redirect_to('/users');

	} else {
		$self->render(template => 'example/loginform', loginError => 1);
	}
};

sub login {
	my $self = shift;
	$self->render(template => 'example/loginform');
};

sub logout {
	my $self = shift;
	$self->session(id => '');
	$self->session(email => '');
	$self->redirect_to('/login');
};

1;