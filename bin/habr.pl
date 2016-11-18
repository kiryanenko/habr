#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long;
use Local::Habr;
use JSON::XS;
use XML::Simple qw(:strict);
use DDP;

use 5.010;  # for say, given/when
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

my $command = shift;

my ($format, $name, $id, $post, $n);
my $refresh = '';
GetOptions(
	'format=s' => \$format,
	'name=s' => \$name,
	'id=i' => \$id,
	'post=i' => \$post,
	'n=i' => \$n,
	'refresh' => \$refresh
);

my $struct;
given ($command) {
	when ('user') {
		if (defined $name) { $struct = Local::Habr::get_user_by_name($name, $refresh); }
		elsif (defined $post) { $struct = Local::Habr::get_user_by_post($post, $refresh); }
		elsif (defined $id) {}
		else { die "Неизвестный ключ" }
	}
	when ('commenters') {
		if (defined $post) { $struct = Local::Habr::get_commenters_in_post($post, $refresh); }
		else { die "Неизвестный ключ" }
	}
	when ('post') {
		if (defined $id) { $struct = Local::Habr::get_post($id, $refresh); }
		else { die "Неизвестный ключ" }
	}
	when ('self_commentors') { Local::Habr::self_commentors; }
	when ('desert_posts') {
		if (defined $n) { $struct = Local::Habr::desert_posts($n); }
		else { die "Неизвестный ключ" }
	}
	default { die 'Неизвестная команда!' }
}

given ($format) {
	when ('json') { say JSON::XS::encode_json($struct); }
	when ('ddp') { p $struct; }
	default { say JSON::XS::encode_json($struct); }
}
