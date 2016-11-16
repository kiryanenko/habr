package Local::Config;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @db = (
	'dbi:Pg:habr:localhost:5432',
	'perl',
	'123456'
);

our %memcach = {
	servers => [
		{address => 'localhost:11211', weight => 2.5},
		'192.168.254.2:11211',
		'/path/to/unix.sock'
	],
	namespace => 'my:',
	connect_timeout => 0.2,
};

1;
