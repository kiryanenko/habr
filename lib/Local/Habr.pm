package Local::Habr;

use strict;
use warnings;

use My::Schema;
use DDP;
use Cache::Memcached::Fast;
use JSON::XS;
use LWP::UserAgent;
use HTML::DOM;
use Local::Config;

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
	
	my $struct = Cache::Memcached::Fast->new(%Local::Config::memcach)->get($key);
	return unless $struct;
	return JSON::XS::decode_json $struct;
}

sub set_memcached {
	my $key = shift;
	my $struct = shift;
	
	Cache::Memcached::Fast->new( %Local::Config::memcach )->set( $key, encode_json($struct), 60 );
}

sub find_user_by_name {
	my $name = shift;
	
	my $user = get_memcached($name);
	return $user if $user;
	
	my $schema = My::Schema->connect( @Local::Config::db );
	if (defined( $user = $schema->resultset('User')->find({name => $name}) )) {
		set_memcached $name, $user;
		return $user;
	}
	
	my $html = LWP::UserAgent->new()->get("http://habrahabr.ru/users/$name/");
	if ($res->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($html);
  		$dom_tree->close;
  		
  		my $karma = $dom_tree->getElementsByClassName('voting-wjt__counter-score')->[0]->innerHTML;
  		my $rating = $dom_tree->getElementsByClassName('statistic__value')->[0]->innerHTML;
  		
  		if (defined $karma && defined $rating) {
	  		$user = { karma => $karma, rating => $rating };
	  		$schema->resultset('User')->create($user);
			set_memcached $name, $user;
		}
	}
	$schema->disconnect;
	return $user;
}



1;
