package Local::Habr;

use strict;
use warnings;

use My::Schema;

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my $schema = My::Schema->connect('dbi:Pg:habr:localhost:5432', 'perl', '123456');

my $user = $schema->resultset('User')->create(
	{ name => 'qwerty'},
);

sub find_user_by_name {
	my $name = shift;
	
	my $user = $schema->resultset('User')->find({name => $name});
	p $user;
}



1;
