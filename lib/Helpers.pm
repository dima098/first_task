package Helpers;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($self, $app) = @_;
	$app->helper(logged => sub {
		my $self = shift;
		my $dbh = $self->db;
		my $email = $self->session('email');
		my $id = $self->session('id');
		my $query = $dbh->prepare('select * from users where email=? and id=?');
		$query->execute($email, $id);

 		while (my $hash = $query->fetchrow_hashref) {
	 		$self->stash(user => $hash);
		}

		return 1 if $query->rows > 0;
		$self->render(template => 'example/loginform');
		return undef;
	});

	$app->helper(user => sub {
		my $self = shift;
		return $self->stash('user');
	});
}

1;