package Local::Habr;

use strict;
use warnings;

use My::Schema;
use Cache::Memcached::Fast;
use JSON::XS;
use LWP::UserAgent;
use HTML::DOM;
use Local::Config;
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
		
		my $schema = My::Schema->connect( @Local::Config::db );
		if (defined( my $user = $schema->resultset('User')->find({name => $name}) )) { 
			$res = { name => $user->name, karma => $user->karma, rating => $user->rating };
			set_memcached $name, $res;
			return $res;
		}
	}
	
	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/users/$name/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

  		my $karma = 0 + $dom_tree->getElementsByClassName('voting-wjt__counter-score js-karma_num')->[0]->as_text;
  		my $rating = 0 + $dom_tree->getElementsByClassName('statistic__value statistic__value_magenta')->[0]->as_text;

  		if (defined $karma && defined $rating) {
	  		$res = { name => $name, karma => $karma, rating => $rating };
	  		my $schema = My::Schema->connect( @Local::Config::db );
	  		if ( $refresh and my $user = $schema->resultset('User')->find({name => $name}) ) { $user->update($res); }
	  		else { $schema->resultset('User')->create($res); }
			set_memcached $name, $res;
		}
	}
	
	return $res;
}

sub get_user_by_post {
	my $post = shift;
	my $refresh = shift;
	my $res;
	
	unless ($refresh) {
		my $schema = My::Schema->connect( @Local::Config::db );
		if (defined( my $post = $schema->resultset('Post')->find($post) )) {
			my $user = $post->author;
			$res = { name => $user->name, karma => $user->karma, rating => $user->rating };
			set_memcached $user->name, $res;
			return $res;
		}
	}

	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/post/$post/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

		$dom_tree->getElementsByClassName('author-info__nickname')->[0]->as_text =~ /@(\w+)/;
		my $author = $1;
		my $theme = $dom_tree->getElementsByClassName('post__title')->[0]->as_text;
  		my $views = 0 + $dom_tree->getElementsByClassName('views-count_post')->[0]->as_text;
  		my $rating = 0 + $dom_tree->getElementsByClassName('js-mark')->[0]->as_text;

  		if ( defined $author && defined $theme && defined $views && defined $rating ) {
	  		$res = get_user_by_name($author, $refresh);
	  		
	  		my $schema = My::Schema->connect( @Local::Config::db );
	  		my $post_rec = {
	  			id => $post,
	  			author => $schema->resultset('User')->find({name => $author}), 
	  			theme => $theme, 
	  			views => $views, 
	  			rating => $rating
	  		};
	  		if ( $refresh and my $post = $schema->resultset('Post')->find($post) ) { $post->update($post_rec); }
	  		else { $schema->resultset('Post')->create($post_rec); }
		}
	}
	
	return $res;
}

sub get_commenters_of_post {
	my $post = shift;
	my $refresh = shift;
	my $res;
	
	unless ($refresh) {
		my $schema = My::Schema->connect( @Local::Config::db );
		if (defined( my $post = $schema->resultset('Post')->find($post) )) {
			my $user = $post->author;
			$res = { name => $user->name, karma => $user->karma, rating => $user->rating };
			set_memcached $user->name, $res;
			return $res;
		}
	}

	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/post/$post/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

		$dom_tree->getElementsByClassName('author-info__nickname')->[0]->as_text =~ /@(\w+)/;
		my $author = $1;
		my $theme = $dom_tree->getElementsByClassName('post__title')->[0]->as_text;
  		my $views = 0 + $dom_tree->getElementsByClassName('views-count_post')->[0]->as_text;
  		my $rating = 0 + $dom_tree->getElementsByClassName('js-mark')->[0]->as_text;

  		if ( defined $author && defined $theme && defined $views && defined $rating ) {
	  		$res = get_user_by_name($author, $refresh);
	  		
	  		my $schema = My::Schema->connect( @Local::Config::db );
	  		my $post_rec = {
	  			id => $post,
	  			author => $schema->resultset('User')->find({name => $author}), 
	  			theme => $theme, 
	  			views => $views, 
	  			rating => $rating
	  		};
	  		if ( $refresh and my $post = $schema->resultset('Post')->find($post) ) { $post->update($post_rec); }
	  		else { $schema->resultset('Post')->create($post_rec); }
		}
	}
	
	return $res;
}

1;
