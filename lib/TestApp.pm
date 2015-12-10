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
      use Mojo::JSON::Pointer;
use Data::Dumper;

my $pointer = Mojo::JSON::Pointer->new({foo => [{name => 'd'}, {name => 'f'}] } );
print Dumper($pointer->get('/foo/0/name'));
  		$c->logged;
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




}


1;
