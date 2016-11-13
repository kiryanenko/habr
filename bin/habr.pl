#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Getopt::Long;
use Local::Habr;

BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';


my $command = shift;

my ($format, $user, $id, $post, $n)
GetOptions(
	'format=s' => \$format,
	'name=s' => \$name,
	'id=s' => \$id,
	'post=s' => \$post,
	'n=s' => \$n
);

given ($command) {
	when ('user') {
		if (defined $name) {
			
		}
		elsif (defined $post) {}
		elsif (defined $id) {}
		else { die "Неизвестный ключ" }
	}
	when ('commenters') {}
	when ('post') {}
	when ('self_commentors') {}
	when ('desert_posts') {}
}
