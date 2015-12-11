package TestApp::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::UserAgent;
use Data::Dumper;

my $clients = {};

sub buttonColor {
  	my $self = shift;
  	$self->render(template => 'example/button');
};

sub squareColor {	
  	my $self = shift;
  	$self->render(template => 'example/square');};

sub socket {
    my $self = shift;
    my $id = sprintf "%s", $self->tx;
    print Dumper($id);
    $clients->{$id} = $self->tx;
    $self->on(json => sub {
        my ($self, $hash) = @_;
        $hash->{msg} = "echo: $hash->{msg}";
        $self->send({json => $hash});
        for (keys %$clients) {
            $clients->{$_}->send({json => $hash});
        }
    }
    );
};

1;
