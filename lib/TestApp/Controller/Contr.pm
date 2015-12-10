package TestApp::Controller::Contr;
use Mojo::Base 'Mojolicious::Controller';
use DBI;
use Digest::MD5 qw(md5 md5_hex);
use Mojolicious::Sessions;
use Mojo::Upload;
use Data::Dumper;
use Mojo::UserAgent;
use Mojolicious::Validator;

	sub api {
		my $c = shift;
		my $param = $c->param('sparam');
		my $dbh = $c->dbcon;
		my $query;
		my $arrJson = [];

		if ($param ne '')
 		{
			$query = $dbh->prepare('SELECT * FROM users WHERE name like \'%'.$param.'%\' or email like \'%'.$param.'%\'');
		}
		else
		{
			$query = $dbh->prepare('SELECT * FROM users');
		}
		
		$query->execute();

		while (my @arr = $query->fetchrow_array())
		{
			push $arrJson, {
							id => $arr[0],
			 				name => $arr[1],
			  				email => $arr[2],
			   				pass => $arr[3],
			    			money => $arr[5],
			     			updated => $arr[6],
			      			created => $arr[7],
			 				image => $arr[8]
			 				};
		}

		$c->render(json => {status => 'ok', users => $arrJson});

	};

	sub uploadPost {
		my $c = shift;
		my $filename = $c->param('image')->filename;

		if (lc $filename =~ /(.png|.jpg)$/)
		{
			my $file = $c->req->upload('image');
        	$file->move_to("public/images/aaa.pl");
        	$c->redirect_to('/users');
		}
		else
		{

		}



	};
	sub upload {

		shift->render(template => 'example/testupload');
	};

	sub login {
		my $c = shift;
		$c->render(template => 'example/loginform');
	};

	sub logout {
		my $c = shift;
		#clean session
		$c->session->{email} = '';
		$c->redirect_to('/login');
	};

	sub authorisation {

		my $c = shift;

 		my $dbh = $c->dbcon;
 		my $email = $c->param('email');
 		my $password = ($c->param('password'));
 		my $query = $dbh->prepare('SELECT * FROM users WHERE email=\''.$email.'\' and pass=\''.$password.'\'');
 		$query->execute();

 		$c->session->{email} = $email;
 		$c->session(expiration => 604800);
		
 		if ($query->rows > 0)
 		{

 			$c->redirect_to('/users');

 			#запись сессии
 		}
 		else
 		{
 			$c->render(template => 'example/loginform', message => "Error of authorisation! Try again!");
 		}

	};

	sub getUsers {
		my $c = shift;

 		my $dbh = $c->dbcon;
 		my $param = $c->param('sparam');
 		my $query;
 		my $email = $c->stash('email');

  		#my $ua = Mojo::UserAgent->new(max_redirects => 5);
  		#my $tx = $ua->get('latest.mojolicio.us');
  		#$tx->res->content->asset->move_to('mojo.tar.gz');


 		if ($param ne '')
 		{
			$query = $dbh->prepare('SELECT * FROM users WHERE name like \'%'.$param.'%\' or email like \'%'.$param.'%\'');
		}
		else
		{
			$query = $dbh->prepare('SELECT * FROM users');
		}


		
		$query->execute();

		$c->render(template => 'example/table', message => $query, email => $email);

	};

	sub removeUser {

		my $c = shift;
		my $dbh = $c->dbcon;
		my $id = $c->stash('id');
		my $query = $dbh->prepare("DELETE FROM users WHERE id = $id");
		$query->execute;
		$c->flash(messageFlash => 'User has removed');
		$c = $c->redirect_to('/users');
	};

	sub addUser {

		my $c = shift;
		$c->render(template => 'example/form', money => 0);

	};

	sub addUserPost {
		my $c = shift;

		my $name = $c->param('name');
		my $password = $c->param('password');
		my $passwordRepeat = $c->param('passwordRepeat');
		my $email = $c->param('email');
		my $money = $c->param('money');
		my $filename = $c->param('image')->filename;
		my $arrErrors = [validatePassword($password, $passwordRepeat), validateEmail($c ,$email), validateMoney($money), validateFile($filename)];
		my $summary = $arrErrors->[0] + $arrErrors->[1] + $arrErrors->[2] + $arrErrors->[3];
		
		if (!$summary)
		{

			my $file = $c->req->upload('image');
			my $newName = makeUniqueFileName($name, $email, $filename);
	        $file->move_to("public/images/".$newName);

			my $dbh = $c->dbcon;
			my $query = $dbh->prepare('INSERT INTO users (name, pass, email, money, photo) VALUES(?,?,?,?,?)');
			$query->execute($name, $password, $email, $money, "images/".$newName);
	        	
			$c->flash(messageFlash => 'User has added');

			$c->redirect_to('/users'); 
		}
		else
		{
			$c->render(template => 'example/form', 
				email => $email,
				emailError => $arrErrors->[1],
				name => $name, money => $money,
				moneyError => $arrErrors->[2],
				passwordError => $arrErrors->[0],
				fileError => $arrErrors->[3]); 
		}
		
	};

	sub changeUser {

		my $c = shift;
		my $id = $c->param('id');
		my $name;
		my $email;
		my $money;
		my $dbh = $c->dbcon;
		my $query = $dbh->prepare('SELECT name, email, money FROM users WHERE id='.$id);
		$query->execute();

		while (my @arr = $query->fetchrow_array)
		{
			$name = $arr[0];
			$email = $arr[1];
			$money = $arr[2];
		}

		$c->render(template => 'example/form', name => $name, email => $email, money => $money, id => $id);
	};

	sub changeUserPost {

		my $c = shift;

		my $name = $c->param('name');
		my $password = $c->param('password');
		my $passwordRepeat = $c->param('passwordRepeat');
		my $email = $c->param('email');
		my $money = $c->param('money');
		my $filename = $c->param('image')->filename;
		my $arrErrors = [validatePasswordForChange($password, $passwordRepeat), validateEmailChange($c, $email), validateMoney($money), validateFile($filename)];
		my $summary = $arrErrors->[0] + $arrErrors->[1] + $arrErrors->[2] + $arrErrors->[3];
		
		if (!$summary)
		{
			my $dbh = $c->dbcon;
			
			if ($filename ne '')
			{
				my $file = $c->req->upload('image');
				my $newName = makeUniqueFileName($name, $email, $filename);
	        	$file->move_to("public/images/".$newName);

	        	my $query = $dbh->prepare('UPDATE users SET photo=? WHERE id=?');
				$query->execute("images/".$newName, $c->stash('id'));
	    	}
			
			if (!wontChange($password, $passwordRepeat))
			{
				print 'UPDATE users SET name=?, password=?, email=?, money=? WHERE id=?';
				my $query = $dbh->prepare('UPDATE users SET name=?, pass=?, email=?, money=? WHERE id=?');
				$query->execute($name, $password, $email, $money, $c->stash('id'));
			}
			else
			{
				my $query = $dbh->prepare('UPDATE users SET name=?, email=?, money=? WHERE id=?');
				$query->execute($name, $email, $money, $c->stash('id'));
			}
			$c->flash(messageFlash => 'User has changed');
			$c->redirect_to('/users'); 
		}

		$c->render(template => 'example/form', passwordError => $arrErrors->[0], emailError => $arrErrors->[1], moneyError => $arrErrors->[2], fileError => $arrErrors->[3]);
	};


	sub validateEmail {
		my ($c ,$email) = @_;
		my $dbh = $c->dbcon;
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
		my $dbh = $c->dbcon;
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

	sub makeUniqueFileName
	{
		my ($name, $email, $filename) = @_;

		print Dumper(join '', md5_hex(join '', $name, $email, $filename, time), ".", substr($filename, -3));

		return join '', md5_hex(join '', $name, $email, $filename, time), ".", substr($filename, -3);

	}


1;
