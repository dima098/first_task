package TestApp::Controller::Contr;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Digest::MD5 qw(md5 md5_hex);
use Mojolicious::Sessions;
use Mojo::Upload;
use Data::Dumper;
use Mojo::UserAgent;




	sub validateEmail {
		my ($c ,$email) = @_;
		my $dbh = $c->db;
		my $query = $dbh->prepare('SELECT * FROM users where email = \''.$email.'\'');
		$query->execute();

		if ($query->rows == 0 && $email ne '')
		{
			return 0;
		}
		else
		{
			return 1;
		}
	};

	sub validateEmailChange {
		my ($c ,$email) = @_;
		my $dbh = $c->db;
		my $query = $dbh->prepare('SELECT * FROM users where email = \''.$email.'\' and id <>'.$c->stash('id'));
		$query->execute();

		if ($query->rows == 0 && $email ne '')
		{
			return 0;
		}
		else
		{
			return 1;
		}
	};


	sub validatePassword {
		my ($pass, $repeatPass) = @_;

		if (length $pass < 7 || $pass ne $repeatPass)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	};

	sub wontChange {
		my ($pass, $repeatPass) = @_;
		return ($pass eq '' && $repeatPass eq '') ? 1 : 0;
	};

	sub validatePasswordForChange {
		my ($pass, $repeatPass) = @_;
		if (wontChange($pass, $repeatPass) || length $pass >= 7 && $pass eq $repeatPass)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	};

	sub validateMoney {
		my $money = shift;
		return $money >= 0 ? 0 : 1;  
	};

	sub validateFile {
	my $filename = shift;
	if (lc $filename =~ /(.png|.jpg)$/ or $filename eq '')
	{
		return 0;
	}
	else
	{
		return 1;
	}
};


	

1;
