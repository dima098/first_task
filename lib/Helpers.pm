package Helpers;
use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my ($c, $app) = @_;

	$app->helper(logged => sub {
			my $c = shift;
			my $dbh = $c->dbcon;
			my $email = $c->session('email');
 			my $password = ($c->session('pass'));
 			my $query = $dbh->prepare('SELECT * FROM users WHERE email=\''.$email.'\' and pass=\''.$password.'\'');
 			$query->execute();

	 		while (my @arr = $query->fetchrow_array)
	 		{
		 		$c->stash(idLogged => $arr[0]);
				$c->stash(nameLogged => $arr[1]);
				$c->stash(emailLogged => $arr[2]);
				$c->stash(passLogged => $arr[3]);
				$c->stash(moneyLogged => $arr[5]);
				$c->stash(updatedLogged => $arr[6]);
				$c->stash(createdLogged => $arr[7]);
				$c->stash(photoLogged => $arr[8]);
			}

			return 1 if $query->rows > 0;
			$c->render(template => 'example/loginform');
			return undef;

		});
	$app->helper(user => sub {
		my $c = shift;
		my $hash = {};
		$hash->{id} = $c->stash('idLogged');
		$hash->{name} = $c->stash('nameLogged');
		$hash->{email} = $c->stash('emailLogged');
		$hash->{pass} = $c->stash('passLogged');
		$hash->{money} = $c->stash('moneyLogged');
		$hash->{updated} = $c->stash('updatedLogged');
		$hash->{created} = $c->stash('createdLogged');
		$hash->{photo} = $c->stash('photoLogged');
		return $hash;
	 });
}

1;