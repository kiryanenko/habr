package Local::Habr;

use strict;
use warnings;

use Local::Schema;
use Cache::Memcached::Fast;
use JSON::XS;
use Local::Config;
use Local::Parser;
use DDP;

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_memcached {
	my $key = shift;

	my $struct = Cache::Memcached::Fast->new( \%Local::Config::memcach )->get($key);
	return unless $struct;
	return JSON::XS::decode_json $struct;
}

sub set_memcached {
	my $key = shift;
	my $struct = shift;
	
	Cache::Memcached::Fast->new( \%Local::Config::memcach )->set( $key, JSON::XS::encode_json($struct), 60 );
}

sub get_user_by_name {
	my $name = shift;
	my $refresh = shift;
	my $res;
	
	unless ($refresh) {
		$res = get_memcached($name);	
		return $res if $res;
		
		my $schema = Local::Schema->connect( @Local::Config::db );
		if (defined( my $user = $schema->resultset('User')->find({name => $name}) )) { 
			$res = { name => $user->name, karma => $user->karma, rating => $user->rating };
			set_memcached $name, $res;
			return $res;
		}
	}
	
	if (defined( $res = Local::Parser::user($name) )) {
		my $schema = Local::Schema->connect( @Local::Config::db );
		if ( $refresh and my $user = $schema->resultset('User')->find({name => $name}) ) { $user->update($res); }
		else { $schema->resultset('User')->create($res); }
		set_memcached $name, $res;
	}
	
	return $res;
}

sub get_post {
	my $post = shift;
	my $refresh = shift;
	my $res;

	unless ($refresh) {
		my $schema = Local::Schema->connect( @Local::Config::db );
		if (defined( my $post = $schema->resultset('Post')->find({post_id => $post}) )) {
			$res = {
	  			post_id => $post->post_id,
	  			theme => $post->theme, 
	  			views => $post->views, 
	  			rating => $post->rating
	  		};
			return $res;
		}
	}

	if (defined( $res = Local::Parser::post($post) )) {
		my $author = $res->{author};
		my @commenters = $res->{commenters};
		delete $res->{author};
		delete $res->{commenters};
		
		get_user_by_name($author, $refresh);	# обновляю автора в бд

  		my $schema = Local::Schema->connect( @Local::Config::db );
  		my %post_atr = %$res;
  		$post_atr{author} = $schema->resultset('User')->find({name => $author});

  		my $post_record;
  		if ( $refresh and $post_record = $schema->resultset('Post')->find({ post_id => $post }) ) { $post_record->update(\%post_atr); }
  		else { $post_record = $schema->resultset('Post')->create(\%post_atr); }
	  		
  		# добовляю комментаторов в бд
  		$post_record->commenters->delete_all;	  		
  		for ( @commenters ) {
			get_user_by_name($_, $refresh);
			my $user = $schema->resultset('User')->find({ name => $_ });
			unless ( $schema->resultset('Commenter')->find({ user => $user, post => $post_record }) ) {
				$schema->resultset('Commenter')->create({ user => $user, post => $post_record });
			}
		}
	}
	return $res;
}

sub get_user_by_post {
	my $post = shift;
	my $refresh = shift;

	get_post($post, $refresh);
	my $schema = Local::Schema->connect( @Local::Config::db );
	my $post_record = $schema->resultset('Post')->find({ post_id => $post });
	return get_user_by_name( $post_record->author->name, $refresh );
}

sub get_commenters_in_post {
	my $post = shift;
	my $refresh = shift;
	
	get_post($post, $refresh);
	my $schema = Local::Schema->connect( @Local::Config::db );
	my $post_record = $schema->resultset('Post')->find({ post_id => $post });
	my @res = map { get_user_by_name($_->user->name, $refresh); } $post_record->commenters;
	return \@res;
}

sub self_commentors {
	my $schema = Local::Schema->connect( @Local::Config::db );
	my @commenters = $schema->resultset('User')->search(
		{ 'commenters.user_id' => \'= posts.author' }, { join => ['posts', 'commenters'] }
	);
	my @res = map { get_user_by_name($_->name); } @commenters;
	return \@res;
}

sub desert_posts {
	my $n = shift;
	
	my $schema = Local::Schema->connect( @Local::Config::db );
	my @posts = $schema->resultset('Post')->all();
	my @res = map { get_post($_->post_id); } grep { $_->commenters->count < $n; } @posts;
	return \@res;
}

1;
