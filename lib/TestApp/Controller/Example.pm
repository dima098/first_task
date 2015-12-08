package TestApp::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';


# This action will render a template
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

1;
