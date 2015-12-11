package TestApp;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use DBI;

sub startup {
    my $self     = shift;
    $self->plugin('Helpers');
    my $config   = $self  ->plugin('Config');
    my $database = $config->{database};
    my $login    = $config->{login};
    my $password = $config->{password};
    my $dbh      = DBI    ->connect("DBI:mysql:$database", $login, $password);

    $self->helper(db => sub {
    	  return $dbh;
    });

    my $route  = $self ->routes;
    my $auth   = $route->under('/')->to('auth#check');
    make_strict_routes($self, $auth);
    make_free_routes($self, $route);
}

sub make_strict_routes {
    my ($self, $route) = @_;
    $route->get('/users')              ->to('user#list');
    $route->get('/users/add')          ->to('user#createui');
    $route->get('/users/:id/change')   ->to('user#changeui');
    $route->get('/users/:id/remove')   ->to('user#delete');
    $route->get('/logout')             ->to('#logout');
    $route->post('/users/:id/change')  ->to('user#change');
    $route->post('users/add')          ->to('user#create');
};

sub make_free_routes {
    my ($self, $route) = @_;
    $route->get('/login')            ->to('auth#login');
    $route->post('/login')           ->to('auth#authorisation');
    $route->get('/api/users')        ->to('contr#api');
    $route->websocket('/changecolor')->to('example#socket');
    $route->get('/button')           ->to('example#buttonColor');
    $route->get('/square')           ->to('example#squareColor');
};

1;
