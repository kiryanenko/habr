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

  		my $karma = $dom_tree->getElementsByClassName('voting-wjt__counter-score js-karma_num')->[0]->as_text;
  		my $rating = $dom_tree->getElementsByClassName('statistic__value statistic__value_magenta')->[0]->as_text;

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

sub get_post {
	my $post = shift;
	my $refresh = shift;
	my $res;

	unless ($refresh) {
		my $schema = My::Schema->connect( @Local::Config::db );
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

	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/post/$post/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

		$dom_tree->getElementsByClassName('author-info__nickname')->[0]->as_text =~ /@(\w+)/;
		my $author = $1;
		my $theme = $dom_tree->getElementsByClassName('post__title')->[0]->getElementsByTagName('span')->[1]->as_text;
  		my $views = $dom_tree->getElementsByClassName('views-count_post')->[0]->as_text;
  		my $rating = $dom_tree->getElementsByClassName('js-score')->[0]->as_text;

  		if ( defined $author && defined $theme && defined $views && defined $rating ) {
  			get_user_by_name($author, $refresh);	# добовляю автора в бд
  			
  			$res = {
	  			post_id => $post,
	  			theme => $theme, 
	  			views => $views, 
	  			rating => $rating
	  		};
	  		  		
	  		my $schema = My::Schema->connect( @Local::Config::db );
	  		my %post_atr = %$res;
	  		$post_atr{author} = $schema->resultset('User')->find({name => $author});
	  		
	  		my $post_record;
	  		if ( $refresh and $post_record = $schema->resultset('Post')->find({ post_id => $post }) ) { $post_record->update(\%post_atr); }
	  		else { $post_record = $schema->resultset('Post')->create(\%post_atr); }
	  		$post_record->commenters->delete_all;
	  		# добовляю комментаторов в бд
	  		for ( $dom_tree->getElementsByClassName('comment-item__username') ) {
  				my $name = $_->as_text;
  				get_user_by_name($name, $refresh);
  				my $user = $schema->resultset('User')->find({name => $name});
  				unless ( $schema->resultset('Commenter')->find({ user => $user, post => $post_record }) ) {
	  				$schema->resultset('Commenter')->create({ user => $user, post => $post_record });
  				}
  			}
		}
	}
	return $res;
}

sub get_user_by_post {
	my $post = shift;
	my $refresh = shift;

	get_post($post, $refresh);
	my $schema = My::Schema->connect( @Local::Config::db );
	my $post_record = $schema->resultset('Post')->find({ post_id => $post });
	return get_user_by_name( $post_record->author->name, $refresh );
}

sub get_commenters_in_post {
	my $post = shift;
	my $refresh = shift;
	
	get_post($post, $refresh);
	my $schema = My::Schema->connect( @Local::Config::db );
	my $post_record = $schema->resultset('Post')->find({ post_id => $post });
	my @res = map { get_user_by_name($_->user->name, $refresh); } $post_record->commenters;
	return \@res;
}

sub self_commentors {
	my $schema = My::Schema->connect( @Local::Config::db );
	my @commenters = $schema->resultset('Commenter')->search(
		{ 'user_id' => 'post.author' }, { join => 'post' }
	)->search_related('user');
	my @res = map { get_user_by_name($_->name); } @commenters;
	return \@res;
}

sub desert_posts {
	my $n = shift;
	
	my $schema = My::Schema->connect( @Local::Config::db );
	my @posts = $schema->resultset('Post')->all();
	my @res = map { {
	  			post_id => $_->post_id,
	  			theme => $_->theme, 
	  			views => $_->views, 
	  			rating => $_->rating
	  		}; } grep { $_->commenters->count < $n; } @posts;
	return \@res;
}

1;
