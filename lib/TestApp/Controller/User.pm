package TestApp::Controller::User;
use Mojo::Base 'Mojolicious::Controller';
use Digest::MD5 qw(md5 md5_hex);
use Mojo::Upload;
use Data::Dumper;

sub check {
	my $self = shift;
	$self->redirect_to('/users');
	return 1 if $self->stash('id') ne undef;
	$self->redirect_to('/users');
	return undef;
};

sub list {
	my $self  = shift;
	my $dbh   = $self->db;
	my $param = $self->param('sparam');
	my $email = $self->stash('email');
	my $query;

	if ($param ne '') {
		$query = $dbh->prepare('select * from users where name like \'%'.$param.'%\' or email like \'%'.$param.'%\'');
	} else {
		$query = $dbh->prepare('select * from users');
	}

	$query->execute();
	$self->render(template => 'example/table', message => $query, email => $email);
};

sub create {
	my $self        = shift;
	my $hash_params = $self->req->params->to_hash;
	my $filename    = $self->param('image')->filename;
	my $hash_values = {id => $self->stash('idNew'), email => $hash_params->{email}, money => $hash_params->{money}, password => $hash_params->{password}, name => $hash_params->{name}};
	my $hash_errors = validate($self, $hash_params->{email}, $hash_params->{password}, $hash_params->{passwordRepeat}, $hash_params->{money}, $filename);
	my $summary     = scalar(@{ $hash_errors->{email} }) + scalar(@{ $hash_errors->{password} }) + scalar(@{ $hash_errors->{money} }) + scalar(@{ $hash_errors->{filename} });
	
	if (!$summary) {
		my $dbh = $self->db;		
		if ($filename ne '') {
			my $file = $self->req->upload('image');
			my $newName = makeUniqueFileName($hash_params->{name}, $hash_params->{email}, $filename);
	        $file->move_to("public/images/".$newName);
			my $query = $dbh->prepare('insert into users (name, pass, email, money, photo) values(?,?,?,?,?)');
			$query->execute($hash_params->{name}, $hash_params->{password}, $hash_params->{email}, $hash_params->{money}, "images/".$newName);
		} else {
			my $query = $dbh->prepare('insert into users (name, pass, email, money) values(?,?,?,?)');
			$query->execute($hash_params->{name}, $hash_params->{password}, $hash_params->{email}, $hash_params->{money});
		}
        	
		$self->flash(messageFlash => 'User has added');
		$self->redirect_to('/users'); 

	} else {
		$self->render(template => 'example/form', values => $hash_values, errors => $hash_errors);
	}
};

sub change {
	my $self        = shift;
	my $id          = $self->param('id');
	my $hash_params = $self->req->params->to_hash;
	my $filename    = $self->param('image')->filename;
	my $hash_values = {id => $self->stash('idNew'), email => $hash_params->{email}, money => $hash_params->{money}, password => $hash_params->{password}, name => $hash_params->{name}};
	my $hash_errors = validate_for_change($self, $hash_params->{email}, $hash_params->{password}, $hash_params->{passwordRepeat}, $hash_params->{money}, $filename);
	my $summary     = scalar (@ {$hash_errors->{email} }) + scalar (@ {$hash_errors->{password} }) + scalar (@{ $hash_errors->{money} }) + scalar (@{$hash_errors->{filename} });
	
	if (!$summary) {
		my $dbh = $self->db;
		if ($filename ne '') {
			my $file = $self->req->upload('image');
			my $newName = makeUniqueFileName($hash_params->{name}, $hash_params->{email}, $filename);
        	$file->move_to("public/images/".$newName);

        	my $query = $dbh->prepare('update users set photo=? where id=?');
			$query->execute("images/".$newName, $hash_params->{id});
    	}
		
		if (!wontChange($hash_params->{password}, $hash_params->{passwordRepeat})) {
			print 'update users set name=?, password=?, email=?, money=? where id=?';
			my $query = $dbh->prepare('update users set name=?, pass=?, email=?, money=? where id=?');
			print Dumper($hash_params);
			$query->execute($hash_params->{name}, $hash_params->{password}, $hash_params->{email}, $hash_params->{money}, $id);
		} else {
			my $query = $dbh->prepare('update users SET name=?, email=?, money=? where id=?');
			$query->execute($hash_params->{name}, $hash_params->{email}, $hash_params->{money}, $id);
		}
		$self->flash(messageFlash => 'User has changed');
		$self->redirect_to('/users'); 
	}
	$self->render(template => 'example/form', values => $hash_values, errors => $hash_errors);
};

sub delete {
	my $self  = shift;
	my $dbh   = $self->db;
	my $id    = $self->stash('id');
	my $query = $dbh->prepare("delete from users where id = ?");
	$query->execute($id);
	$self->flash(messageFlash => 'User has removed');
	$self     = $self->redirect_to('/users');
};

sub createui {
	my $self        = shift;
	my $hash_values = {money => 0};
	$self->render(template => 'example/form', values => $hash_values);
};

sub changeui {

	my $self        = shift;
	my $id          = $self->param('id');
	my $dbh         = $self->db;
	my $query       = $dbh->prepare('select id, name, email, money from users where id='.$id);
	$query->execute();
	my $hash_values = $query->fetchrow_hashref;
	$self->render(template => 'example/form', values => $hash_values);
};

sub makeUniqueFileName {
	my ($name, $email, $filename) = @_;
	return join '', md5_hex(join '', $name, $email, $filename, time), ".", substr($filename, -3);
}


sub validate {
	my ($self, $email, $password, $password_repeat, $money, $filename) = @_;
	my $hash = {email => [], password => [], money => [], filename => []};
	
	if ($email ne '') {
		my $dbh = $self->db;
		my $query = $dbh->prepare('select * from users where email = ?');
		$query->execute($email);
		if ($query->rows) {
			push $hash->{email}, "Email isn't unique";
		}
	} else {
		push $hash->{email}, "Email is empty";
	}

	if (! length($password) || ! length($password_repeat)) {
		push $hash->{password}, "Password is empty";
	}

	if (length $password > 0 && length $password < 7) {
		push $hash->{password}, "Too short password";
	}

	if ($password ne $password_repeat) {
		push $hash->{password}, "Passwords aren't equal";
	}

	if ($money < 0) {
		push $hash->{money}, "Value is negative";
	}

	if (lc $filename =~ /(.png|.jpg)$/ or $filename eq ''){
	} else {
		push $hash->{filename}, "Wrong file format";	
	}

	return $hash;
};

sub validate_for_change {
	my ($self, $email, $password, $password_repeat, $money, $filename) = @_;
	my $hash = {email => [], password => [], money => [], filename => []};
	
	if ($email ne '') {
		my $dbh = $self->db;
		my $query = $dbh->prepare('select * from users where email = ? and id <> ?');
		$query->execute($email, $self->stash('id'));
		if ($query->rows) {
			push $hash->{email}, "Email isn't unique";
		}
	} else {
		push $hash->{email}, "Email is empty";
	}

	if (length $password > 0 && length $password < 7) {
		push $hash->{password}, "Too short password";
	}

	if ($password ne $password_repeat) {
		push $hash->{password}, "Passwords aren't equal";
	}

	if ($money < 0) {
		push $hash->{money}, "Value is negative";
	}

	if (lc $filename =~ /(.png|.jpg)$/ or $filename eq ''){
	} else {
		push $hash->{filename}, "Wrong file format";	
	}

	return $hash;
};

sub wontChange {
	my ($pass, $repeatPass) = @_;
	return ($pass eq '' && $repeatPass eq '') ? 1 : 0;
};

1;