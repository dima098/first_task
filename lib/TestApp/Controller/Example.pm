package TestApp::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;
use Data::Dumper;

my $clients = {};

sub buttonColor {
	my $c = shift;
	$c->render(template => 'example/button');
};

sub squareColor {	
	my $c = shift;
	$c->render(template => 'example/square');};

sub socket {

  my $c = shift;
  my $id = sprintf "%s", $c->tx;
  print Dumper($id);
  $clients->{$id} = $c->tx;

  $c->on(json => sub {
      my ($c, $hash) = @_;
      $hash->{msg} = "echo: $hash->{msg}";
      $c->send({json => $hash});
      for (keys %$clients) {
          $clients->{$_}->send({json => $hash});
      }
  }
  );
};

1;
