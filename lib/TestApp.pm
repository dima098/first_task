package TestApp;
use Mojo::Base 'Mojolicious';

use Data::Dumper;
use DBI;



sub startup {
  my $self = shift;

  $self->plugin('PODRenderer');
  $self->plugin('Helpers');
  my $database = "TESTDB";
  my $login = "root";
  my $password = "";
  my $dbh = DBI->connect("DBI:mysql:$database", $login, $password);

  $self->helper(dbcon => sub {
  	return $dbh;
  	});


  my $r = $self->routes;


  my $auth = $r->under('/' => sub{
  		my $c = shift;

  		my $email = $c->session('email');
 		my $password = ($c->session('pass'));
 		my $query = $dbh->prepare('SELECT * FROM users WHERE email=\''.$email.'\' and pass=\''.$password.'\'');
 		$query->execute();

 		while (my @arr = $query->fetchrow_array)
 		{
	 		$c->stash(id => $arr[0]);
			$c->stash(name => $arr[1]);
			$c->stash(email => $arr[2]);
			$c->stash(pass => $arr[3]);
			$c->stash(money => $arr[5]);
			$c->stash(updated => $arr[6]);
			$c->stash(created => $arr[7]);
			$c->stash(photo => $arr[8]);
		}


  		return 1 if $query->rows > 0;

  		$c->render(template => 'example/loginform');

  		return undef;
  	});

  $r->get('/login')->to('contr#login');
  $r->post('/login')->to('contr#authorisation');
  $r->get('/api/users')->to('contr#api');
  $auth->get('/users')->to(controller => 'contr', action =>'getUsers');
  $auth->get('/users/add')->to(controller => 'contr', action =>'addUser');
  $auth->post('users/add')->to(controller => 'contr', action =>'addUserPost');
  $auth->get('/users/:id/change')->to('contr#changeUser');
  $auth->post('/users/:id/change')->to('contr#changeUserPost');
  $auth->get('/users/:id/remove')->to('contr#removeUser');
  $auth->get('/logout')->to('contr#logout');
  $r->get('/test')->to('example#test');
  $r->websocket('/changecolor')->to('example#socket');
  $r->get('/button')->to('example#buttonColor');
  $r->get('/square')->to('example#squareColor');

  $r->post('/upload')->to('contr#uploadPost');
  $r->get('/upload')->to('contr#upload');



}


1;
