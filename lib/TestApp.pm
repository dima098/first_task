package TestApp;
use Mojo::Base 'Mojolicious';
use Mojo::Transaction::WebSocket;

use DBI;
sub startup {
  my $self = shift;

  $self->plugin('PODRenderer');

  my $database = "TESTDB";
  my $login = "root";
  my $password = "";
  my $dbh = DBI->connect("DBI:mysql:$database", $login, $password);



my $ws = Mojo::Transaction::WebSocket->new;
$ws->send('Hello World!');
$ws->on(message => sub {
  my ($ws, $msg) = @_;
  say "Message: $msg";
});
$ws->on(finish => sub {
  my ($ws, $code, $reason) = @_;
  say "WebSocket closed with status $code.";
});

  #$self->plugin('TestApp::Helpers');
  $self->helper(dbcon => sub {
  	return $dbh;
  	});

  my $r = $self->routes;


  my $auth = $r->under('/' => sub{
  		my $c = shift;
  		#$c->render(text => 'Authorisation form');

  		return 1;

  		$c->render(template => 'example/loginform');

  		return undef;
  	});

  $r->get('/login')->to('contr#login');
  $r->post('/login')->to('contr#authorisation');
  $auth->get('/users')->to(controller => 'contr', action =>'getUsers');
  $auth->get('/users/add')->to(controller => 'contr', action =>'addUser');
  $auth->post('users/add')->to(controller => 'contr', action =>'addUserPost');
  $auth->get('/users/:id/change')->to('contr#changeUser');
  $auth->post('/users/:id/change')->to('contr#changeUserPost');
  $auth->get('/users/:id/remove')->to('contr#removeUser');
  $auth->get('/logout')->to('contr#logout');



}


1;
