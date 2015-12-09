package TestApp::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;
use Data::Dumper;
# This action will render a template
my $clients = {};
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(text => 'Welcome to the Mojolicious real-time web framework!');
}

sub goodbye {
	my $self = shift;

	$self->render(text => "goodbye");
};

sub fun {
	my $self = shift;

	$self->render(text => "fun");
};

sub test {
	my $c = shift;
	my $ua = Mojo::UserAgent->new;
	my $value = $ua->get('https://sri:s3cret@example.com/test.json')->res->json;
	print Dumper($value);
	$c->render(text => "test");
};

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

  });};

1;
